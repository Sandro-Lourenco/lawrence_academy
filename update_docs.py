
import re

def update_file(filepath, content_updater):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = content_updater(content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

def update_status(c):
    c = re.sub(r'PROJECT_STABLE', 'RC1_APPROVED', c)
    return c

def update_backlog(c):
    return c + '\n- [x] RC1 Homologation completed and approved.\n'

update_file('PROJECT_STATUS.md', update_status)
update_file('IMPLEMENTATION_BACKLOG.md', update_backlog)
update_file('TECH_DEBT_BACKLOG.md', update_backlog)
