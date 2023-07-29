function make-bitbake
    #--------------------- VARIABLE ---------------------#
    # init variables
    set -g APP_NAME         $argv[1]
    set -g BRANCH           $argv[2]
    set -g PUSH_OPTION      $argv[3]
    set -g SOURCE_PATH      "/drive/Storage/$USER/source-code"
    set -g BIT_BAKE_PATH    "$SOURCE_PATH/meta-mango2"
    set -g APP_PATH         "$SOURCE_PATH/$APP_NAME"
    set -g APP_RECIPES      "$BIT_BAKE_PATH/recipes-app/$APP_NAME"
    set -g COMMIT_MSG_FILE  "/home/$USER/.cache/tmp-commit-msg.txt"
    set -g GIT_BINARY       '/usr/bin/git'

    # runtime variables
    set -g CURRENT_TAG      ''
    set -g NEW_SUBMISSIONS  ''
    set -g OLD_TAG_REF      ''
    set -g NEW_TAG_REF      ''
    set -g SOURCE_BRANCH    ''
    set -g OLD_SUBMISSIONS  ''
    set -g IS_MASTER        'no'
    set -g LAST_TAGGED      'no'
    set -g LIST_ISSUES      ''
    set -g LIST_COMMITS     ''

    # color palette
    set -g bad              'FF7676'
    set -g medium           'EBE769'
    set -g good             '84FF76'
    set -g reset            'normal'

    #--------------------- FUNCTION ---------------------#
    # This function to write a log with color
    # First parameter is color, ex: "CACACA"
    # Second parameter is message, ex: "Such nice weather over here"
    function logger
        set_color $argv[1]; echo $argv[2]; set_color normal
    end

    # This function is the same with function logger
    # but doesn't add line break after wrote the message
    function logger_one_line
        set_color $argv[1]; echo -n $argv[2]; set_color normal
    end

    # This function is used for resetting a local git repo
    # First parameter is the branch name to checkout before reset
    function git_reset
        git reset --hard HEAD -q; or return 1
        git checkout -q $argv[1]; or return 1
        git clean -f -d -q; or return 1
        git reset --hard HEAD^^^ -q; or return 1
        git pull -q; or return 1
        return 0
    end

    # This function check a variable is whether a number or not
    # First parameter is the variable need to be checked
    # return 0 if true
    # return 1 if false
    function is_number
        string match -qr '^[0-9]+$' $argv[1]; 
            and return 0;
            or return 1;
    end

    # This function is used for 
    #   Checking the existence of source code and meta-mango directory
    #   Validating the input arguments
    function validate
        logger $medium "[VALIDATE]"
        # Check app name input
        test -z "$APP_NAME"; and begin; logger $bad "Missing App Name"; return 1; end
        # Check branch input
        test -z "$BRANCH"; and begin; logger $bad "Missing Branch"; return 1; end
        # Check git installed
        test -e "$GIT_BINARY"; or begin; echo -e "Git is not installed.\nRun below command to install git:\n    sudo apt install git"; return 1; end
        # Check app path exist
        test -d "$APP_PATH"
            and logger $good "$APP_PATH -----> OK"
            or begin
                logger $bad "$APP_PATH -----> NOK"
                return 1
            end
        # Check meta-mango exist
        test -d "$BIT_BAKE_PATH"
            and logger $good "$BIT_BAKE_PATH -----> OK"
            or begin
                logger $bad "$BIT_BAKE_PATH ----> NOK"
                return 1
            end
        return 0
    end

    # This function is used for getting the source code branch
    # which currently apply on the meta-mango branch
    # sometimes, they are different
    function get_source_code_branch
        logger $medium "[GET_SOURCE_CODE_BRANCH]"
        cd $APP_RECIPES
        git_reset $BRANCH; or return 1
        set -l tmp_branch   (grep PAP_VERSION $APP_NAME.bb | sed 's/"//g' | cut -d'-' -f2 | cut -d'_' -f1)
        is_number $tmp_branch; 
            and begin
                set OLD_SUBMISSIONS "submissions/$tmp_branch"
                set SOURCE_BRANCH   'master'
                set IS_MASTER       'yes'
                logger_one_line $good "Is master branch: "; echo "$IS_MASTER"
                logger_one_line $good "Old submissions: " ; echo "$OLD_SUBMISSIONS"
            end
            or begin
                set -l tmp_tag_number   (echo $tmp_branch | tr '.' '\n' | tail -n1)
                set OLD_SUBMISSIONS     "submissions/$tmp_branch"
                set SOURCE_BRANCH       "@"(echo $tmp_branch | sed "s/\.$tmp_tag_number//g")
                set IS_MASTER           'no'
                logger_one_line $good "Is master branch: "  ; echo "$IS_MASTER"
                logger_one_line $good "Source code branch: "; echo "$SOURCE_BRANCH"
                logger_one_line $good "Old submissions: "   ; echo "$OLD_SUBMISSIONS"
            end
        test -z "$OLD_SUBMISSIONS"; and return 1
        test -z "$SOURCE_BRANCH"; and return 1
        return 0
    end

    # This function is used for creating new tag for the source code
    # If no need to create, then it will be ignored automatically
    # If no need to make commit, then the script will be aborted
    function make_tag
        logger $medium "[MAKE_TAG]"
        cd $APP_PATH
        git_reset $SOURCE_BRANCH; or return 1
        # Get current tag
        set CURRENT_TAG     (git describe)
        logger_one_line $good "Current git describe: "; echo "$CURRENT_TAG"
        # Extract tag
        set -l nearest_tag  (echo $CURRENT_TAG | cut -d'-' -f1)
        logger_one_line $good "Nearest tag: "; echo "$nearest_tag"
        test "$nearest_tag" = "$CURRENT_TAG"
            and begin; 
                echo "Latest commit was tagged"; 
                set LAST_TAGGED     'yes'
                set NEW_SUBMISSIONS $CURRENT_TAG;
                test "$NEW_SUBMISSIONS" = "$OLD_SUBMISSIONS"; 
                    and begin;
                        logger $bad "Latest submissions was merged on meta-mango -----> Abort"
                        return 1
                    end
                return 0; 
            end
            or begin;
                echo "Make new tag for latest commit"
                set LAST_TAGGED 'no'
            end

        # Get the nearest tag number
        set -l nearest_tag_number
        test "$SOURCE_BRANCH" = 'master';
            and set nearest_tag_number  (echo $nearest_tag | cut -d'/' -f2);
            or  set nearest_tag_number  (echo $nearest_tag | tr '.' '\n' | tail -n1);
        # Make new tag number by add 1
        set -l new_tag_number  (math $nearest_tag_number + 1)
        # If new tag number < 10 -> new_tag_number = "0" + new_tag_number
        test $new_tag_number -lt 10; 
            and set new_tag_number "0$new_tag_number"

        # Make new submissions for master or another branch
        test "$SOURCE_BRANCH" = 'master'
            and set NEW_SUBMISSIONS "submissions/$new_tag_number"
            or begin
                set -l br (echo $SOURCE_BRANCH | sed 's/@//')
                set NEW_SUBMISSIONS "submissions/$br.$new_tag_number"
            end
        logger_one_line $good "Created new tag: "; echo "$NEW_SUBMISSIONS"
        return 0
    end

    # This function is used for pushing the new tag to git server
    function push_tag
        logger $medium "[PUSH_TAG]"
        logger_one_line $good "LAST COMMIT IS TAGGED: "; echo $LAST_TAGGED
        test "$LAST_TAGGED" = 'no'
            and begin
                git tag -a $NEW_SUBMISSIONS -m $NEW_SUBMISSIONS; or return 1
                git push origin $NEW_SUBMISSIONS; or return 1
            end
        set NEW_TAG_REF (git show-ref (git describe) | cut -d' ' -f1)
        set OLD_TAG_REF (git show-ref $OLD_SUBMISSIONS | cut -d' ' -f1)
        logger_one_line $good "Old tag ref: "; echo $OLD_TAG_REF
        logger_one_line $good "New tag ref: "; echo $NEW_TAG_REF
        test -z "$OLD_TAG_REF"; and return 1
        test -z "$NEW_TAG_REF"; and return 1
        return 0
    end

    # This function is used for modify the bitbake repo (in this case: meta-mango)
    function modify_meta_mango
        logger $medium "[MODIFY_META_MANGO]"
        cd $BIT_BAKE_PATH/recipes-app/$APP_NAME

        # Modify bitbake
        set -l tmp_old_ref  (echo $OLD_SUBMISSIONS | cut -d'/' -f2)"_$OLD_TAG_REF"
        set -l tmp_new_ref  (echo $NEW_SUBMISSIONS | cut -d'/' -f2)"_$NEW_TAG_REF"
        sed -i "s/$tmp_old_ref/$tmp_new_ref/" $APP_NAME.bb
        git diff -U1 --no-indent-heuristic; or return 1
        return 0
    end

    # This function create commit message and save somewhere
    function create_message
        logger $medium "[CREATE_MESSAGE]"
        test -e "$COMMIT_MSG_FILE"; 
            and begin
                rm $COMMIT_MSG_FILE
                echo "Remove old commit message file: $COMMIT_MSG_FILE"
            end
        cd $APP_PATH

        # set list issues and commits
        set LIST_ISSUES     (git log --oneline --pretty=format:"%s" $OLD_SUBMISSIONS..$NEW_SUBMISSIONS)
        set LIST_COMMITS    (git log --oneline $OLD_SUBMISSIONS..$NEW_SUBMISSIONS)
        # get short submissions
        set -l short_submissions    (echo $NEW_SUBMISSIONS | cut -d'/' -f2)
        # get title
        set -l msg_title            ''
        test $BRANCH = 'master';
            and set msg_title "$APP_NAME=$short_submissions"
            or  set msg_title "[PGEN5][$APP_NAME][EV_ONLY][M_A] $APP_NAME=$short_submissions"
        
        # Start writing Commit message
        echo $msg_title                                 >  $COMMIT_MSG_FILE
        echo                                            >> $COMMIT_MSG_FILE
        # Release note
        echo ":Release Note:"                           >> $COMMIT_MSG_FILE
        echo "@@@$APP_NAME"                             >> $COMMIT_MSG_FILE
        echo "<Issue>"                                  >> $COMMIT_MSG_FILE
        for issue in $LIST_ISSUES; 
            echo "* $issue"                             >> $COMMIT_MSG_FILE 
        end
        echo                                            >> $COMMIT_MSG_FILE
        echo "!!!"                                      >> $COMMIT_MSG_FILE
        echo                                            >> $COMMIT_MSG_FILE
        echo "[Commit List]"                            >> $COMMIT_MSG_FILE
        echo "TAG: $OLD_SUBMISSIONS..$NEW_SUBMISSIONS"  >> $COMMIT_MSG_FILE
        for commit in $LIST_COMMITS; 
            echo $commit                                >> $COMMIT_MSG_FILE 
        end
        echo                                            >> $COMMIT_MSG_FILE
        # Relate app
        echo ":RelateApp:"                              >> $COMMIT_MSG_FILE
        echo "None"                                     >> $COMMIT_MSG_FILE
        echo                                            >> $COMMIT_MSG_FILE
        # Test method
        echo ":Test Method:"                            >> $COMMIT_MSG_FILE
        echo "MiniBAT"                                  >> $COMMIT_MSG_FILE
        logger $good "Commit message is written to $COMMIT_MSG_FILE"
        return 0
    end

    # This function commit all changed with the commit message created before
    function commit_changed
        logger $medium "[COMMIT_CHANGED]"
        set -l push_opt_list    '-lc' '--local'
        contains -- "$PUSH_OPTION" $push_opt_list;
        if test $status -eq 0
            logger $good "Local commit !!! This is the message:"
            cat $COMMIT_MSG_FILE
            return 0
        else
            logger $good "Push all changed to git server."
        end

        cd $APP_RECIPES
        git add $APP_NAME.bb; or return 1
        git commit --file=$COMMIT_MSG_FILE; or return 1
        git push origin HEAD:refs/for/$BRANCH; or return 1
        return 0
    end

    # This is the main of the script
    function main_script
        logger_one_line $good "Start commit meta-mango for branch: "; echo $BRANCH;
        validate; or return 1
        get_source_code_branch; or return 1
        make_tag; or return 1
        push_tag; or return 1
        modify_meta_mango; or return 1
        create_message; or return 1
        commit_changed; or return 1
        return 0
    end

    #----------------------- MAIN -----------------------#
    main_script; 
        and begin
            logger_one_line $medium  "[RESULT] "
            logger          $good    "SUCCESFUL"
            return 0
        end
        or begin
            logger_one_line $medium  "[RESULT]"
            logger          $bad     " FAILURE"
            return 1
        end

end
