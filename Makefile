THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH));pwd)
THIS_MAKEFILE:=$(notdir $(THIS_MAKEFILE_PATH))
SRC_PERL = $(wildcard plbin/*.pl)
SRC_PYTHON = $(wildcard pybin/*.py)
BIN_DIR = $(THIS_DIR)/bin
BIN_PERL = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PERL))))
BIN_PYTHON = $(addprefix $(BIN_DIR)/,$(basename $(notdir $(SRC_PYTHON))))

clean:
	rm $(THIS_DIR)/bin/*

gather:
	mkdir -p $(THIS_DIR)/lib/Bio
	mkdir -p $(THIS_DIR)/lib/Bio/P3
	mkdir -p $(THIS_DIR)/lib/Bio/KBase
	mkdir -p $(THIS_DIR)/lib/biop3/
	mkdir -p $(THIS_DIR)/lib/biop3/ProbModelSEED
	mkdir -p $(THIS_DIR)/lib/biop3/Workspace
	if [ -d $(THIS_DIR)/../auth ] ; then \
		rm -rf $(THIS_DIR)/lib/Bio/KBase/*.pm ; \
		mkdir $(THIS_DIR)/lib/Bio/KBase/SSHAgent ; \
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthUser.pm $(THIS_DIR)/lib/Bio/KBase/AuthUser.pm ; \
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthConstants.pm $(THIS_DIR)/lib/Bio/KBase/AuthConstants.pm ; \
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/AuthToken.pm $(THIS_DIR)/lib/Bio/KBase/AuthToken.pm ; \
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/Auth.pm $(THIS_DIR)/lib/Bio/KBase/Auth.pm ; \
		cp $(THIS_DIR)/../auth/Bio-KBase-Auth/lib/Bio/KBase/SSHAgent/*.pm $(THIS_DIR)/lib/Bio/KBase/SSHAgent/ ; \
	fi
	if [ -d $(THIS_DIR)/../ProbModelSEED ] ; then \
		cp $(THIS_DIR)/../ProbModelSEED/scripts/*.pl $(THIS_DIR)/plbin/ ; \
		cp $(THIS_DIR)/../ProbModelSEED/scripts/*.py $(THIS_DIR)/pybin/ ; \
		rm -rf $(THIS_DIR)/lib/Bio/ModelSEED/ProbModelSEED ; \
		mkdir $(THIS_DIR)/lib/Bio/ModelSEED/ProbModelSEED ; \
		cp $(THIS_DIR)/../ProbModelSEED/lib/Bio/ModelSEED/ProbModelSEED/ProbModelSEEDClient.pm $(THIS_DIR)/lib/Bio/ModelSEED/ProbModelSEED/ProbModelSEEDClient.pm ; \
		cp $(THIS_DIR)/../ProbModelSEED/lib/biop3/ProbModelSEED/*.py $(THIS_DIR)/lib/biop3/ProbModelSEED/ ; \
	fi
	if [ -d $(THIS_DIR)/../MSSeedSupportServer ] ; then \
		rm -rf $(THIS_DIR)/lib/Bio/ModelSEED/MSSeedSupportServer ; \
		mkdir $(THIS_DIR)/lib/Bio/ModelSEED/MSSeedSupportServer ; \
		cp $(THIS_DIR)/../MSSeedSupportServer/lib/Bio/ModelSEED/MSSeedSupportServer/Client.pm $(THIS_DIR)/lib/Bio/ModelSEED/MSSeedSupportServer/Client.pm ; \
	fi
	if [ -d $(THIS_DIR)/../Workspace ] ; then \
		cp $(THIS_DIR)/../Workspace/scripts/*.pl $(THIS_DIR)/plbin/ ; \
		rm -rf $(THIS_DIR)/lib/Bio/P3/Workspace ; \
		mkdir $(THIS_DIR)/lib/Bio/P3/Workspace ; \
		cp $(THIS_DIR)/../Workspace/lib/Bio/P3/Workspace/WorkspaceClient.pm $(THIS_DIR)/lib/Bio/P3/Workspace/WorkspaceClient.pm ; \
		cp $(THIS_DIR)/../Workspace/lib/Bio/P3/Workspace/WorkspaceClientExt.pm $(THIS_DIR)/lib/Bio/P3/Workspace/WorkspaceClientExt.pm ; \
		cp $(THIS_DIR)/../Workspace/lib/Bio/P3/Workspace/ScriptHelpers.pm $(THIS_DIR)/lib/Bio/P3/Workspace/ScriptHelpers.pm ; \
		cp $(THIS_DIR)/../Workspace/lib/Bio/P3/Workspace/Utils.pm $(THIS_DIR)/lib/Bio/P3/Workspace/Utils.pm ; \
		cp $(THIS_DIR)/../Workspace/lib/biop3/Workspace/*.py $(THIS_DIR)/lib/biop3/Workspace/ ; \
	fi
	if [ -d $(THIS_DIR)/../ModelSEED ] ; then \
		rm -rf $(THIS_DIR)/lib/myRAST ; \
		mkdir $(THIS_DIR)/lib/myRAST ; \
		cp $(THIS_DIR)/../ModelSEED/lib/myRAST/ClientTHing.pm $(THIS_DIR)/lib/myRAST ; \
		rm -rf $(THIS_DIR)/lib/ModelSEED/Client ; \
		mkdir $(THIS_DIR)/lib/ModelSEED/Client ; \
		cp $(THIS_DIR)/../ModelSEED/lib/ModelSEED/Client/SAP.pm $(THIS_DIR)/lib/ModelSEED/Client/ ; \
	fi
	if [ -d $(THIS_DIR)/../app_service ] ; then \
		cp $(THIS_DIR)/../app_service/scripts/appserv-* $(THIS_DIR)/plbin/ ; \
		rm -rf $(THIS_DIR)/lib/Bio/KBase/AppService ; \
		mkdir $(THIS_DIR)/lib/Bio/KBase/AppService ; \
		cp $(THIS_DIR)/../app_service/lib/Bio/KBase/AppService/Client.pm $(THIS_DIR)/lib/Bio/KBase/AppService/Client.pm ; \
		cp $(THIS_DIR)/../app_service/lib/Bio/KBase/AppService/Util.pm $(THIS_DIR)/lib/Bio/KBase/AppService/Util.pm ; \
	fi

all: 
	for src in $(SRC_PERL) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $(THIS_DIR) $$src $$base ; \
		bash wrap_perl.sh $(THIS_DIR) $$src "bin/$$base" ; \
	done
	for src in $(SRC_PYTHON) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .py`; \
		echo install $(THIS_DIR) $$src $$base ; \
		bash wrap_python.sh $(THIS_DIR) $$src "bin/$$base" ; \
	done
