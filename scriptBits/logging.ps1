#PowerShell Logging Script
#SharePointJack.com
 
#Tip, if viewing on my blog, click the full screen icon in the toolbar above
 
# "Global" variables:
# the filename is scoped here
# this creates a log file with a date and time stamp
$logfile = "C:\Scratch\YourLogFileNameGoesHere_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"
 
#this is our logging function, it must appear above the code where you are trying to use it.
#note there is a technique to get around needing this at the top, read the blog post to find out more...
function log($string, $color)
{
   if ($Color -eq $null) {$color = "white"}
   write-host $string -foregroundcolor $color
   $string | out-file -Filepath $logfile -append
}
 
# examples:
# log something
log "this is a simple output string, it will appear white"
 
# log with color on screen:
log "This string will appear yellow on screen" yellow
log "This will appear red" red
 
# powershell shortcuts useful for building strings:
$myvariable = "hello"
log "$myvariable world"
 
# include double quotes in your string:
log "`"this was quoted`""  #NOTE: This character is the tick (top left of a US keyboard) - it doesn't look like it comes across in this blog.
 
# use more than simple variables in a string:
$cmds = get-command
log "there are $($cmds.count) commands available"