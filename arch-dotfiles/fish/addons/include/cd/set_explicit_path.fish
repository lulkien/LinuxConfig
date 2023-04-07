function set_explicit_path
    string length -q "$argv"; or set argv "$HOME"
    test "$argv" = '.'; and set argv (realpath .)
    test "$argv" = '..'; and set argv (realpath ..)
    echo $argv
end
