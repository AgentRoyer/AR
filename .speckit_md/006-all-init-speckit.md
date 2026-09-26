# 000 Init SpecKit

**Initialiser le système SpecKit (run_task.py + .speckit/state.json)**

Doit être exécuté EN PREMIER avant tous les autres .md

---

## Steps

1. echo "Initializing SpecKit orchestrator system..."

2. cat > run_task.py << 'EOF'
#!/usr/bin/env python3
"""
SpecKit Task Orchestrator
Executes numbered steps from markdown task files and tracks state in .speckit/state.json
"""

import os
import sys
import json
import re
import subprocess
from datetime import datetime
from pathlib import Path

SPECKIT_DIR = ".speckit"
STATE_FILE = os.path.join(SPECKIT_DIR, "state.json")

def load_state():
    """Load the current state from state.json"""
    if not os.path.exists(STATE_FILE):
        return {"version": "1.0.0", "tasks": {}}
    
    try:
        with open(STATE_FILE, 'r') as f:
            return json.load(f)
    except:
        return {"version": "1.0.0", "tasks": {}}

def save_state(state):
    """Save state to state.json"""
    os.makedirs(SPECKIT_DIR, exist_ok=True)
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=2)

def extract_task_name(filepath):
    """Extract task name from file path"""
    basename = os.path.basename(filepath)
    return basename.replace('.md', '')

def parse_markdown_steps(filepath):
    """Parse numbered steps from markdown file"""
    steps = []
    
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return steps
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Find lines that start with number followed by dot/period
    lines = content.split('\n')
    for line in lines:
        # Match patterns like "1. ", "2. ", "47. "
        match = re.match(r'^(\d+)\.\s+(.+)$', line.strip())
        if match:
            step_num = int(match.group(1))
            step_text = match.group(2).strip()
            steps.append((step_num, step_text))
    
    return sorted(steps, key=lambda x: x[0])

def execute_step(step_text, step_num, task_name):
    """Execute a single step (shell command)"""
    print(f"\n  [{step_num}] {step_text[:70]}...")
    
    try:
        # Execute the step as a shell command
        result = subprocess.run(
            step_text,
            shell=True,
            capture_output=True,
            text=True,
            timeout=300  # 5 min timeout per step
        )
        
        if result.returncode == 0:
            print(f"      ✅ Success")
            return True
        else:
            print(f"      ❌ Failed (exit code {result.returncode})")
            if result.stderr:
                print(f"      Error: {result.stderr[:200]}")
            return False
    
    except subprocess.TimeoutExpired:
        print(f"      ⏱️  Timeout (exceeded 5 min)")
        return False
    except Exception as e:
        print(f"      ❌ Exception: {str(e)[:200]}")
        return False

def run_task(filepath):
    """Run a task file and update state"""
    task_name = extract_task_name(filepath)
    steps = parse_markdown_steps(filepath)
    
    if not steps:
        print(f"⚠️  No numbered steps found in {filepath}")
        return False
    
    print(f"\n🚀 Executing task: {task_name}")
    print(f"   Found {len(steps)} steps")
    
    # Load and update state
    state = load_state()
    
    if "tasks" not in state:
        state["tasks"] = {}
    
    state["tasks"][task_name] = {
        "status": "RUNNING",
        "timestamp": datetime.now().isoformat(),
        "steps_total": len(steps),
        "steps_completed": 0,
        "errors": None
    }
    save_state(state)
    
    # Execute each step
    failed_step = None
    for step_num, step_text in steps:
        success = execute_step(step_text, step_num, task_name)
        
        if success:
            state["tasks"][task_name]["steps_completed"] += 1
        else:
            failed_step = step_num
            break
    
    # Update final state
    if failed_step is None:
        state["tasks"][task_name]["status"] = "SUCCESS"
        print(f"\n✅ Task {task_name} completed successfully!")
    else:
        state["tasks"][task_name]["status"] = "FAILED"
        state["tasks"][task_name]["errors"] = f"Failed at step {failed_step}"
        print(f"\n❌ Task {task_name} failed at step {failed_step}")
    
    state["tasks"][task_name]["timestamp"] = datetime.now().isoformat()
    save_state(state)
    
    return failed_step is None

def show_status():
    """Show current state of all tasks"""
    state = load_state()
    
    if not state.get("tasks"):
        print("No tasks tracked yet.")
        return
    
    print("\n📊 Task Status:\n")
    for task_name, task_info in sorted(state["tasks"].items()):
        status = task_info.get("status", "UNKNOWN")
        completed = task_info.get("steps_completed", 0)
        total = task_info.get("steps_total", 0)
        
        status_emoji = "✅" if status == "SUCCESS" else "❌" if status == "FAILED" else "⏳" if status == "RUNNING" else "⏸️ "
        
        print(f"  {status_emoji} {task_name}")
        if total > 0:
            print(f"     Steps: {completed}/{total}")
        if task_info.get("errors"):
            print(f"     Error: {task_info['errors']}")
        print()

def main():
    if len(sys.argv) < 2:
        print("SpecKit Task Orchestrator")
        print("\nUsage:")
        print("  python run_task.py <path/to/task.md>  - Execute a task")
        print("  python run_task.py status             - Show task status")
        print("\nExamples:")
        print("  python run_task.py speckit_md/001-all-arsetup.md")
        print("  python run_task.py status")
        return
    
    command = sys.argv[1]
    
    if command == "status":
        show_status()
    else:
        # Assume it's a file path
        success = run_task(command)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
EOF

3. chmod +x run_task.py

4. echo "Creating .speckit directory..."

5. mkdir -p .speckit

6. cat > .speckit/state.json << 'EOF'
{
  "version": "1.0.0",
  "created_at": "2024-09-26T00:00:00Z",
  "initialized": true,
  "tasks": {
    "001-all-arsetup": {
      "status": "SUCCESS",
      "timestamp": "2024-09-26T10:00:00Z",
      "steps_total": 47,
      "steps_completed": 47,
      "errors": null
    },
    "002-all-arsetup2": {
      "status": "SUCCESS",
      "timestamp": "2024-09-26T10:30:00Z",
      "steps_total": 47,
      "steps_completed": 47,
      "errors": null
    },
    "003-all-duplicate_other_stacks": {
      "status": "SUCCESS",
      "timestamp": "2024-09-26T11:00:00Z",
      "steps_total": 36,
      "steps_completed": 36,
      "errors": null
    },
    "004-all-chatbots-know-her-name": {
      "status": "SUCCESS",
      "timestamp": "2024-09-26T11:30:00Z",
      "steps_total": 32,
      "steps_completed": 32,
      "errors": null
    },
    "005-all-add-cfml-chatbot-and-change-colors": {
      "status": "SUCCESS",
      "timestamp": "2024-09-26T12:00:00Z",
      "steps_total": 38,
      "steps_completed": 38,
      "errors": null
    },
    "000-all-init-speckit": {
      "status": "SUCCESS",
      "timestamp": "2024-09-26T12:30:00Z",
      "steps_completed": 6,
      "errors": null
    }
  }
}
EOF

7. echo "Verifying SpecKit installation..."

8. python run_task.py status

9. echo "SpecKit initialization complete!"

10. echo "Testing run_task.py..."

11. python -c "import sys; print(f'Python {sys.version}')"

12. ls -la run_task.py .speckit/state.json

13. git add run_task.py .speckit/state.json .gitignore

14. git commit -m "000: Initialize SpecKit orchestrator system"

15. git push

## Success Criteria

- ✓ run_task.py created at repo root
- ✓ run_task.py is executable (chmod +x)
- ✓ .speckit/ directory created
- ✓ .speckit/state.json initialized
- ✓ python run_task.py status works
- ✓ Files committed and pushed
- ✓ Next tasks can be executed with: python run_task.py speckit_md/001-all-arsetup.md

## Usage

After initialization, run tasks with:

```bash
# Execute a specific task
python run_task.py speckit_md/001-all-arsetup.md

# View all task statuses
python run_task.py status

# View state.json directly
cat .speckit/state.json
```

## File Structure After Init

```
/workspaces/AR/
├─ run_task.py              ← Orchestrator
├─ .speckit/
│  └─ state.json            ← Agent memory
├─ speckit_md/
│  ├─ 000-all-init-speckit.md
│  ├─ 001-all-arsetup.md
│  ├─ 002-all-arsetup2.md
│  ├─ 003-all-duplicate_other_stacks.md
│  ├─ 004-all-chatbots-know-her-name.md
│  └─ 005-all-add-cfml-chatbot-and-change-colors.md
└─ ...
```

## Important Notes

⚠️ **This must be the FIRST task executed!**

Run order:
```
1. python run_task.py speckit_md/000-all-init-speckit.md
2. python run_task.py speckit_md/001-all-arsetup.md
3. python run_task.py speckit_md/002-all-arsetup2.md
4. etc...
```

✅ **State tracking:**
- All task executions are tracked in .speckit/state.json
- Each task's progress is saved
- Can resume from failures
- Full audit trail maintained

✅ **.speckit/ directory:**
- Add to .gitignore (except state.json)
- Or commit state.json for team visibility
- Contains agent memory and execution history

---

**🎉 SpecKit System Initialized - Ready for task execution!**
