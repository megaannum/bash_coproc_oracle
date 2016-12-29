# bash_coproc_oracle

example of bash coproc managing oracle sqlplus connection

----

# Usage

In a bash script, 
    source the bash_coproc_oracle.sh, 
    setup a TRAP so that "sqlplus_exit" is called on exit
    and then initialize the coproc with "sqlplus_init $schema"


    #!/bin/bash

    #.....

    # load sqlplus coproc code
    . $LOCATION_OF_SCRIPT/bash_coproc_oracle.sh
    
    #.....

    # close sqlplus connection on exit
    trap sqlplus_exit EXIT

    #.....

    # initialize coproc
    sqlplus_init "$schema"
