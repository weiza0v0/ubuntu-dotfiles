c = get_config()  # noqa

# Auto-load icat extension for %icat magic (display images in kitty)
c.InteractiveShellApp.extensions = ['icat']

# Don't auto-enable icat's matplotlib backend override --
# we use MPLBACKEND=module://matplotlib-backend-kitty instead
c.InteractiveShellApp.exec_lines = []
