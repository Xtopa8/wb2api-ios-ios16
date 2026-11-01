import sys

TC = '/home/ubuntu/work/doris/wb-eval/merged/internal/panel/taskcenter.go'
PG = '/home/ubuntu/work/doris/wb-eval/merged/internal/panel/panel.go'

s = open(TC, encoding='utf-8').read()
if 'abortRequested' in s:
    print('已打过补丁，跳过')
    sys.exit(0)

old_state = '''type queueState struct {
	mu        sync.Mutex
	running   bool
	startedAt time.Time
	items     []queueItem
	conc      int
	seq       int
}'''
new_state = '''type queueState struct {
	mu             sync.Mutex
	running        bool
	startedAt      time.Time
	items          []queueItem
	conc           int
	seq            int
	abortRequested bool
}'''
assert old_state in s, 'state 锚点缺失'
s = s.replace(old_state, new_state, 1)

old_loop = '''				p.queueMarkAt(i, "running", "")
				outcome := autoTaskOutcome{Status: "error", Message: "未知的任务类型"}'''
new_loop = '''				// 暂停检查：收到 abort 就把剩余项标 skipped
				if q.abortPending() {
					p.queueMarkAt(i, "skipped", "已暂停")
					continue
				}
				p.queueMarkAt(i, "running", "")
				outcome := autoTaskOutcome{Status: "error", Message: "未知的任务类型"}'''
assert old_loop in s, 'loop 锚点缺失'
s = s.replace(old_loop, new_loop, 1)

old_defer = '''	q := p.queue()
	startedAt := time.Now()
	defer func() {
		q.mu.Lock()
		q.running = false'''
new_defer = '''	q := p.queue()
	startedAt := time.Now()
	defer func() {
		q.mu.Lock()
		q.running = false
		q.abortRequested = false'''
assert old_defer in s, 'defer 锚点缺失'
s = s.replace(old_defer, new_defer, 1)

anchor = '// tasksQueueStatus 队列状态（轮询用）。'
assert anchor in s, 'status 锚点缺失'
pause_code = '''// abortPending 原子读取并清零暂停标记（暂停指令只生效一次）。
func (q *queueState) abortPending() bool {
	q.mu.Lock()
	defer q.mu.Unlock()
	if q.abortRequested {
		q.abortRequested = false
		return true
	}
	return false
}

// tasksPauseQueue 暂停执行队列：置 abort 位；当前正在执行的那一项会跑完
//（上游调用不可中断），其余 pending 项在下一次检查点被标 skipped。
func (p *Panel) tasksPauseQueue(w http.ResponseWriter, r *http.Request) {
	q := p.queue()
	q.mu.Lock()
	q.abortRequested = true
	running := q.running
	q.mu.Unlock()
	if running {
		log.Printf("panel: 队列暂停请求已受理（当前项完成后停止）")
		writeJSON(w, http.StatusOK, map[string]any{"ok": true, "message": "暂停中：当前任务完成后停止"})
	} else {
		writeJSON(w, http.StatusOK, map[string]any{"ok": true, "message": "队列当前空闲"})
	}
}

'''
s = s.replace(anchor, pause_code + anchor, 1)
open(TC, 'w', encoding='utf-8').write(s)
print('taskcenter.go patched')

g = open(PG, encoding='utf-8').read()
if 'tasks/pause' not in g:
    route_old = 'p.mux.HandleFunc("POST /panel/api/tasks/run_queue", p.withAuth(p.tasksRunQueue))'
    assert route_old in g, '路由锚点缺失'
    g = g.replace(route_old, route_old + '\n\tp.mux.HandleFunc("POST /panel/api/tasks/pause", p.withAuth(p.tasksPauseQueue))', 1)
    open(PG, 'w', encoding='utf-8').write(g)
    print('panel.go route added')
else:
    print('路由已存在')
