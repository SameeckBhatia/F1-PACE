import subprocess

# List of libraries to install
libraries = ['pandas', 'requests', 'bs4']

# Install each library
for lib in libraries:
    subprocess.check_call(['pip', 'install', lib])

print("\nAll libraries installed successfully!")
