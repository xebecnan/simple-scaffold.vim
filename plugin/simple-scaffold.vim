" Author: xebecnan https://github.com/xebecnan
" Description: some scaffold functions to create new files for my projects

fun! GetTemplateDir()
    if !exists('g:arnantemplates')
        let tpl = fnamemodify($VIM, ":p") . "arnantemplates"
        return fnamemodify(l:tpl, ":p")
    else
        return g:arnantemplates
    endif
endfun

fun! FindLuaDir()
    let path = fnamemodify(".", ":p:h")
    let found = 0
    while 1
        if index(readdir(l:path), "Assets") >= 0
            let s1 = fnamemodify(l:path, ":p") . "Assets"
            if index(readdir(l:s1), "Lua") >= 0
                let s2 = fnamemodify(l:s1, ":p") . "Lua"
                let found = 1
                break
            endif
        endif
        let prevpath = l:path
        let path = fnamemodify(path, ":h")
        if path ==? l:prevpath
            break
        endif
    endwhile
    if !l:found
        return ""
    else
        return l:s2
    endif
endfun

fun! FindGameSFUDir()
    let path = fnamemodify(".", ":p:h")
    let found = 0
    while 1
        if index(readdir(l:path), "Assets") >= 0
            let s1 = fnamemodify(l:path, ":p") . "Assets"
            if index(readdir(l:s1), "Scripts") >= 0
                let s2 = fnamemodify(l:s1, ":p") . "Scripts"
                if index(readdir(l:s2), "GameSFU") >= 0
                    let found = 1
                    break
                endif
            endif
        endif
        let prevpath = l:path
        let path = fnamemodify(path, ":h")
        if path ==? l:prevpath
            break
        endif
    endwhile
    if !l:found
        return ""
    else
        return fnamemodify(l:s2, ":p") . "GameSFU"
    endif
endfun

fun! WriteTemplate(tpl_filename, fname, name, altername)
    let tpl = GetTemplateDir()
    let tpl = fnamemodify(l:tpl, ":p") . a:tpl_filename
    let content = readfile(l:tpl)
    for i in range(len(l:content))
        let content[l:i] = substitute(l:content[l:i], '<altername>', a:altername, "g")
        let content[l:i] = substitute(l:content[l:i], '<name>', a:name, "g")
    endfor
    call writefile(l:content, a:fname)
endfun

fun! ConcatPath(parts)
    let path = ""
    for part in a:parts
        if l:path == ""
            let path = l:part
        else
            let path = fnamemodify(l:path, ":p") . l:part
        endif
    endfor
    return l:path
endfun

fun! TrimEnding(str, ending)
    " Check if the string ends with the specified ending
    if matchstr(a:str, '.*' . escape(a:ending, '\.*$') . '$') !=# ''
        " Trim the specified ending and return the modified string
        return substitute(a:str, escape(a:ending, '\.*$') . '$', '', '')
    else
        " Return the original string if it doesn't end with the specified ending
        return a:str
    endif
endfun

fun! ScaffoldForConfig(name)
    if a:name !~ '^\u'
        echo "name should begin with a capital letter:" . a:name
        return
    endif

    let trimed_name = TrimEnding(a:name, "Config")

    let altername = substitute(l:trimed_name, '\u', '\l&', '')
    let altername = substitute(l:altername, '\u', '_\l&', 'g')

    let config_dir = FindGameSFUDir()
    let config_filename = ConcatPath([l:config_dir, l:trimed_name . "Config.cs"])
    let editor_filename = ConcatPath([l:config_dir, "Editor", "ConfigEditor", l:trimed_name . "Editor.cs"])

    call WriteTemplate("NewConfig.cs", l:config_filename, l:trimed_name, l:altername)
    call WriteTemplate("NewConfigEditor.cs", l:editor_filename, l:trimed_name, l:altername)

    exec "vs " . l:config_filename
    exec "vs " . l:editor_filename
endfun

fun! ScaffoldForSkill(name)
    if a:name !~ '^SKLG_[_A-Z]\+$'
        echo "name should be all capital letters:" . a:name
        return
    endif

    let filename = substitute(a:name[5:], '\u', '\l&', 'g')

    let lua_dir = FindLuaDir()
    let lua_filename = ConcatPath([l:lua_dir, "skill", l:filename . ".lua"])

    call WriteTemplate("skill_template.lua", l:lua_filename, a:name, '')

    exec "vs " . l:lua_filename
endfun

command! -nargs=1 NewConfig     call ScaffoldForConfig(<q-args>)
command! -nargs=1 NewSkill      call ScaffoldForSkill(<q-args>)
