function fish_prompt
    # Get kubernetes namespace
    set -l kube_ns (kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)

    # Fallback to default
    if test -z "$kube_ns"
        set kube_ns "default"
    end

    # Make it colorful
    set -p kube_ns (set_color cyan)
    set -a kube_ns (set_color normal)


    # Get kubernetes context
    set -l kube_ctx (cat ~/.kube/config 2> /dev/null | grep "current-context:" | sed "s/current-context: //")
    set -l kube_ctx_col green

    # Make it red if prod
    switch "$kube_ctx"
        case '*prod*'
        set kube_ctx_col red
    end

    set -p kube_ctx (set_color $kube_ctx_col)
    set -a kube_ctx (set_color normal)

    # Get git branch
    set -l git_branch ( git_branch_name )

    # If git is dirty then make branch red
    if git_is_dirty
        set -p git_branch (set_color red)
        set -a git_branch (set_color normal)
    else
        set -p git_branch (set_color green)
        set -a git_branch (set_color normal)
    end

    # Set prompt suffix
    set -l suffix ">"

    # If user is root, set suffix to #
    if test $USER = root
        set suffix "#"
    end

    # Build prompt string
    if test -n kube_ctx
        set -a prompt_str $kube_ctx
    end

    if test -n kube_ns
        set -a prompt_str ':' $kube_ns
    end

    set -a prompt_str ' ' (prompt_pwd)

    if test -n git_branch
        set -a prompt_str ' (' $git_branch ') '
    end

    set -a prompt_str $suffix ' '

    echo -n -s $prompt_str
end   
