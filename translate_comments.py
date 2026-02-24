import os
import re

# We will just print the lines with Arabic comments first to see the volume
count = 0
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart') and 'l10n' not in root:
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for i, line in enumerate(lines):
                if re.search(r'//.*[\u0600-\u06FF]', line):
                    print(f"{path}:{i+1}:{line.strip()}")
                    count += 1
print(f"Total Arabic comment lines: {count}")
