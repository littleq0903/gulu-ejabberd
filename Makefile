
# Git repository urls
URL_GIT_EJABBERD="https://github.com/processone/ejabberd.git"
URL_GIT_EXMPP="https://github.com/processone/exmpp.git"
URL_GIT_ERLMONGO="https://github.com/wpntv/erlmongo.git"
URL_GIT_MOD_CHAT_LOG_MONGODB="git@github.com:gage/mod_chat_log_mongodb.git"
URL_GIT_MOD_ADMIN_EXTRA_CUSTOM="git@github.com:gage/mod_admin_extra_custom.git"

# Functions
fetch_from_git = cd repo && git clone $(1)
reset_to_head = git reset --hard && git pull origin master

all: task1 task2

repo: 
	mkdir repo

build:
	mkdir build

# fetch commands
repo/exmpp: repo
	$(call fetch_from_git,$(URL_GIT_EXMPP))

repo/erlmongo: repo
	$(call fetch_from_git,$(URL_GIT_ERLMONGO))

repo/mod_chat_log_mongodb: repo
	$(call fetch_from_git,$(URL_GIT_MOD_CHAT_LOG_MONGODB))

repo/mod_admin_extra_custom: repo
	$(call fetch_from_git,$(URL_GIT_MOD_ADMIN_EXTRA_CUSTOM))

repo/ejabberd: repo
	$(call fetch_from_git,$(URL_GIT_EJABBERD))

fetch_repo: repo/ejabberd repo/exmpp repo/erlmongo repo/mod_chat_log_mongodb repo/mod_admin_extra_custom

#build commands
build/exmpp: build repo/exmpp
	cd repo/exmpp && autoreconf -i && ./configure && make && sudo make install
	
build/mod_chat_log_mongodb: build repo/mod_chat_log_mongodb
	cd repo/mod_chat_log_mongodb && ./build.sh && sudo cp ebin/* /lib/ejabberd/ebin

build/mod_admin_extra_custom: build repo/mod_admin_extra_custom
	cd repo/mod_admin_extra_custom && ./build.sh && sudo cp ebin/* /lib/ejabberd/ebin

build/erlmongo: build repo/erlmongo
	cd repo/erlmongo && erl -make && sudo cp ebin/* /lib/ejabberd/ebin

build/ejabberd: build repo/ejabberd
	ex - repo/ejabberd/src/ejabberd_app.erl < exscript/ejabberd_app.erl.exscript
	cd repo/ejabberd/src && aclocal && autoconf && ./configure && make && sudo make install

# rebuild commands

rebuild/mod_chat_log_mongodb: repo/mod_chat_log_mongodb
	cd repo/mod_chat_log_mongodb && $(call reset_to_head) && \
	./build.sh && sudo cp ebin/* /lib/ejabberd/ebin

rebuild/mod_admin_extra_custom: repo/mod_admin_extra_custom
	cd repo/mod_admin_extra_custom && $(call reset_to_head) && \
	./build.sh && sudo cp ebin/* /lib/ejabberd/ebin

rebuild: rebuild/mod_chat_log_mongodb rebuild/mod_admin_extra_custom


#clean commands
clean_repo:
	rm -rf repo

clean_build:
	rm -rf build

clean: clean_repo clean_build

task1: build/exmpp build/ejabberd

task2: build/mod_admin_extra_custom build/mod_chat_log_mongodb build/erlmongo

