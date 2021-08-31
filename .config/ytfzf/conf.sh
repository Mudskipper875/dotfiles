#!/bin/sh

# ENV VARIABLES
enable_hist=0
enable_loop=1
cache_dir="$HOME/.cache/ytfzf"
enable_cur=1
enable_noti=0
video_pref=""
external_menu="dmenu -i -l 30 -p Search:"
external_menu_len=220
thumb_disp_method="ueberzug"
video_player="devour mpv"
video_player_format="devour mpv --ytdl-format="
audio_player="devour mpv --no-video"
enable_fzf_default_opts=0
selected_sub="eng"

# OPT VARIABLES
is_download=0
enable_search_hist_menu=0
is_ext_menu=0
show_thumbnails=1
thumbnail_quailty=1
is_audio_only=0
auto_select=0
select_all=0
random_select=0
link_count=1
search_again=0
show_link_only=0
silent_mode=0
show_format=0
preview_side="left"
sub_link_count=15
fancy_subscriptions_menu=1
scrape="yt_search"
auto_caption=0
sort_videos_data=0
trending_tab=""
sp=""


# COMMON FILTERS

#the parentheses are options you can pass when running ytfzf

#UPLOAD DATE FILTERS
#last hour: EgIIAQ (--last-hour)
#today: EgQIAhAB (--today)
#this week: EgQIAxAB (--this-week)
#this month: EgQIBBAB (--this-month)
#this year: EgQIBRAB (--this-year)

#DURATION FILTERS
#short: EgQQARgB
#long: EgQQARgC

#FEATURE FILTERS
#live: EgQQAUAB
#4k: EgQQAXAB
#subtitles/cc: EgQQASgB

#SORT BY FILTERS
#upload date: CAISAhAB (--upload-date)
#view count: CAMSAhAB (--view-count)
#rating: CAESAhAB (--rating)

#to combine any of these filters it would be best to go to youtube,
    #filter how you want, then copy the &sp= part of the url

# MISC

# Shortcuts

#the shortcuts to use in fzf
#the first 6 are used for
    # printing the urls
    # printing the title
    # openeing selected urls in a browser
    # watching the video
    # downloading the video
    # listening to the video
    # search again
#in that order, these keys can be changed
#any keys after will not have default behaviour and the behaviour must be defined in handle_custom_shortcuts
shortcuts="alt-l,alt-t,alt-o,alt-v,alt-d,alt-m,alt-s,alt-enter"

#some helpful variables to keep in mind:
    #selected_key: they shortcut pressed
    #selected_urls: the selected urls
    #selected_data: the line that was selected
    #play_url: a function that takes a url and plays it (play_url "$url")
#the return value matters in this function,
    #returning 0 will continue the program as normal
    #returning 1 will exit the program and will clean up after itself
    #returning 2 will restart the main loop (this is used for the search_again shortcut)
handle_custom_shortcuts () {
    return 0
}

# Other

search_prompt="Search : "
useragent="$USERAGENT"
history_file="$cache_dir/ytfzf_hst"
enable_search_hist=1
search_history_file="$cache_dir/ytfzf_search_hst"
search_history_prompt="> "
allow_empty_search_hist=0
current_file="$cache_dir/ytfzf_cur"
thumb_dir="$cache_dir/thumb"
subscriptions_file=$YTFZF_CONFIG_DIR/subscriptions
fancy_subscriptions_text="             -------%s-------"

#this function is called when a video is selected in the menu to send a notification
#available variables
    #$videos_selected_count: the number of videos selected
    #$video_title
    #$video_channel
    #$video_views
    #$video_duration
    #$video_date (the upload date)
    #$video_shorturl (the id of the video)

#with video_title, channel, views, duration, date, and shorturl, be sure to use this syntax
    # ${var#|}, that way the extra | at the start will be removed
send_select_video_notif () {
	#message=$title\nchannel: $channel
        #${var#|} removes the extra | at the start of the text
        message="${video_title#|}\nChannel: ${video_channel#|}"
        video_thumb="$config_dir/default_thumb.png"

        #if more than 1 video selected
        if [ $videos_selected_count -gt 1 ]; then
                message="Added $videos_selected_count video to play queue"
        #if show thumbnails and videos_selected is 1 (it will never be less than 1)
        elif [ "$show_thumbnails" -eq 1 ]; then
                video_thumb="$thumb_dir/${video_shorturl#|}.png"
        fi

	#if downloading, say Downloading not currently playing
        if [ $is_download -eq 1 ]; then
            notify-send "Downloading" "$message" -i "$video_thumb"
        else
            notify-send "Current playing" "$message" -i "$video_thumb"
        fi

        unset message video_thumb
}


###################
#  VIDEO DISPLAY  #
###################

#when using the menu, use the text printed in this function to display all the info, $shorturl must be present in order to work
#available default colors (note: they are be bolded):
    #c_red
    #c_green
    #c_yellow
    #c_blue
    #c_magenta
    #c_cyan
    #c_reset (sets it back to terminal defaults)
#available variables
    #title
    #title_len, the available tty columns for $title
    #channel
    #channel_len, the available tty columns for $channel
    #duration
    #dur_len, the available tty columns for $duration
    #views
    #view_len, the available tty columns for $views
    #date (video upload date)
    #date_len, the vailable tty columns for $date
    #shorturl (the video ID)
video_info_text() {
	printf "%-${title_len}.${title_len}s\t" "$title"
	printf "%-${channel_len}.${channel_len}s\t" "$channel"
	printf "%-${dur_len}.${dur_len}s\t" "$duration"
	printf "%-${view_len}.${view_len}s\t" "$views"
	printf "%-${date_len}.${date_len}s\t" "$date"
	printf "%s" "$shorturl"
	printf "\n"
}


#when displaying thumbnails, use the text printed in this function to show the title, views, etc..
#available default colors (note: they are be bolded):
    #c_red
    #c_green
    #c_yellow
    #c_blue
    #c_magenta
    #title
    #channel
    #duration
    #views
    #date (video upload date)
    #description (the short description seen in search results)
    #shorturl (the video ID)
#how this works:
    #anything printed will stay on the screen in the fzf preview menu
thumbnail_video_info_text () {
         printf "\n ${c_cyan}%s" "$title"
         printf "\n ${c_blue}Channel      ${c_green}%s" "$channel"
         printf "\n ${c_blue}Duration     ${c_yellow}%s" "$duration"
         printf "\n ${c_blue}Views        ${c_magenta}%s" "$views"
         printf "\n ${c_blue}Date         ${c_cyan}%s" "$date"
         printf "\n ${c_blue}Description  ${c_reset}: %s" "$description"
}


#####################
#     SCRIPTING     #
#####################

#############
# Variables #
#############

#when an invlaid opt is given, eg: --this-is-not-an-option it will throw an error and exit when set to 1, otherwise ignore the error
exit_on_opt_error=1

#############
# Functions #
#############

#this function is called when thumbnail_display_method is custom
#parameters:
    #$1: thumb_width
    #$2: thumb_height
    #$3: thumb_x
    #$4: thumb_y
    #$5: IMAGE (path to the image)
handle_display_img () {
    return 0
}

#gets called when an opt gets passed
#paramters
    #$1 will be the opt name
    #$2 will be the opt argument
#eg:
    #ytfzf -a -n2
    #this function will be called twice, on the first time
	#$1 will be a, $2 will be empty
    #on the 2nd time
	#$1 will be n, $2 will be 2
#long options are different
    #ytfzf --link-count=2
    #$1 will be -
    #$2 will be link-count=2
on_opt_parse () {
    return 0
}


#this function is called after videos_data has been set and ytfzf knows it's been set
#parameters
    #$1 will be videos_data
    #$2 will be videos_json
    #$3 will be yt_json
on_video_data_gotten () {
    return 0
}


#this function is called after the search query is gotten, including the initial search used in the command
    #eg: ytfzf search query
#parameters
    #$1 will be the search query
on_get_search () {
    return 0
}

#this function will be called when all instances of ytfzf are closed, and the last one is closed
on_exit () {
    return 0
}

#when this function is set it will be called instead of open_player,
#open_player handles downloading, and showing a video,
#when handle_urls is defined you get all the urls passed in, and can do whatever you want with them,
#you can call open_player yourself, as shown below
handle_urls () {
    open_player $*
}

#############
# Sort Data #
#############

#returns the value that it will use to sort
#parameters
    #$1: video title
    #$2: video channel
    #$3: length of video
    #$4: view count
    #$5: upload date
    #$6: video id
#be sure to use ${var#|} to get rid of the extra | at the start
data_sort_key () {
    sort_by="${5#|}"
    sort_bey="${sort_by#Streamed}"
    #this must return the value to sort by
    printf "%d" "$(date -d "${sort_by}" '+%s')"
    unset sort_by
}

#this can be anything but sort is a builtin function that sorts data
#for random sort set this to "sort -R"
data_sort_fn () {
    sort -nr
}

#a sort-name is a function that sets the values of data_sort_key and data_sort_fn
#it is only necessary to set one of these functions, however it is a good idea to set both for clarity and to be sure it works as intended

alphabetical () {
    data_sort_key () {
	sort_by="${1#|}"
	#since sort by is the title of the video, not the upload date, use %s
	printf "%s" "$sort_by"
	unset sort_by
    }
    data_sort_fn () {
	sort
    }
}

#to use this run, "ytfzf --sort-name=alphabetical <search>"
