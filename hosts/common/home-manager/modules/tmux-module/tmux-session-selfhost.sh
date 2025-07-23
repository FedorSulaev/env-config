if initialize_session "selfhost"; then
    window_root "$HOME/Projects/SelfHosting/"
    new_window "Config"
    run_cmd "nvim"

    window_root "$HOME/Projects/SelfHosting/"
    new_window "ConfigGit"
    run_cmd "lazygit"

    window_root "$HOME/Projects/SelfHosting/"
    new_window "Terminal"
    split_h 50
fi

finalize_and_go_to_session
