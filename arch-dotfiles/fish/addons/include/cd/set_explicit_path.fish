function set_explicit_path
    string length -q "$argv"; or set argv "$HOME"
    set argv (realpath $argv)
    echo $argv
end
