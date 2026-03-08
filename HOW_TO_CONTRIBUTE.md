# How to Contribute to MultiFunkIm-scripts

Welcome to the **MultiFunkIm-scripts** repository! This repository is designed to store and manage internal scripts and processes used by our group. This guide will help you get started with contributing, version control, and best practices for collaboration.

## 1. Getting Started

### Clone the Repository
To work with this repository, start by cloning it to your local machine:
```bash
git clone https://github.com/multifunkim/MultiFunkIm-scripts.git
```

### Set Up Git (If Not Already Done)
Make sure you have Git installed on your system. Configure your Git identity with:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 2. Adding a Script

1. **Create a new branch**
   Always create a new branch when adding or modifying scripts to keep the main branch clean:
   ```bash
   git checkout -b feature-name
   ```
   Example:
   ```bash
   git checkout -b add-signal-processing-script
   ```

2. **Place Your Script in the Appropriate Directory**
   - Organize scripts into appropriate subdirectories based on their purpose.
   - If necessary, create a new directory with a clear name.

3. **Commit Your Changes**
   After adding or modifying scripts, commit your changes:
   ```bash
   git add script_name.py
   git commit -m "Added script for signal processing"
   ```

4. **Push Your Branch to GitHub**
   ```bash
   git push origin feature-name
   ```

5. **Create a Pull Request (PR)**
   - Navigate to the repository on GitHub.
   - Click on **Pull Requests** > **New Pull Request**.
   - Select your branch and submit the PR for review.
   - Add a description of your changes.

6. **Review & Merge**
   - A team member will review your PR and provide feedback.
   - After approval, your changes will be merged into the main branch.

## 3. Best Practices

- **Write Clear and Readable Code**: Follow consistent coding styles and document important parts of your script.
- **Use Meaningful Commit Messages**: Clearly describe what the commit does.
- **Test Before Pushing**: Ensure your script runs correctly before pushing changes.
- **Keep Your Branch Updated**: If the main branch updates while you work, sync your branch:
  ```bash
  git checkout main
  git pull origin main
  git checkout feature-name
  git merge main
  ```

## 4. Issues and Discussions

- **Report Bugs**: If you find a bug, create an issue describing the problem.
- **Suggest Enhancements**: Have an idea to improve a script? Open a discussion or issue!

## 5. Questions?
If you have any questions, feel free to ask within the repository's **Issues** or **Discussions** section.

Happy coding!
