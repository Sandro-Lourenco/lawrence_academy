import os

directory = r'lawrence/lib'

def replace_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content.replace('.withOpacity(', '.withValues(alpha: ')

    if content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {file_path}")

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            replace_in_file(os.path.join(root, file))

print("Flutter update done.")
