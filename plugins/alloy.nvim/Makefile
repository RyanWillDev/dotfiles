ALLOY_VERSION ?= 6.2.0
ALLOY_DIR     ?= $(HOME)/.local/share/alloy
ALLOY_JAR     ?= $(ALLOY_DIR)/alloy.jar
ALLOY_URL     ?= https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v$(ALLOY_VERSION)/org.alloytools.alloy.dist.jar
JDK_CASK      ?= temurin

PARSER_SO     ?= parser/alloy.so

.PHONY: install install-java install-jar update-jar uninstall-jar check doctor \
        parser generate build-parser clean-parser test-parser all

all: install parser

install: install-jar
	@if ! /usr/libexec/java_home -v 11+ >/dev/null 2>&1; then \
		echo; \
		echo "warning: no JDK 11+ detected."; \
		echo "         install one yourself in a real terminal (the cask installer"; \
		echo "         prompts for a password that can't reach make's shell):"; \
		echo "             brew install --cask $(JDK_CASK)"; \
		echo "         then re-run 'make check' to verify."; \
	fi
	@echo
	@echo "Done. Add this to your shell rc if it isn't already:"
	@echo "    export ALLOY_JAR=$(ALLOY_JAR)"

# ---- tree-sitter grammar ----

parser: generate build-parser

generate:
	@command -v tree-sitter >/dev/null || { echo "tree-sitter CLI not found — brew install tree-sitter"; exit 1; }
	tree-sitter generate

build-parser: generate
	@mkdir -p parser
	tree-sitter build --output $(PARSER_SO)
	@echo "built: $(PARSER_SO)"

test-parser: build-parser
	tree-sitter parse examples/river.als --quiet && echo "ok: examples/river.als parses"

clean-parser:
	rm -rf src/parser.c src/tree_sitter $(PARSER_SO)

install-java:
	@if /usr/libexec/java_home -v 11+ >/dev/null 2>&1; then \
		echo "java >= 11 already installed at $$( /usr/libexec/java_home -v 11+ )"; \
		exit 0; \
	fi; \
	command -v brew >/dev/null || { echo "homebrew not found — install from https://brew.sh first"; exit 1; }; \
	if [ ! -t 0 ] || [ ! -t 1 ]; then \
		echo "refusing to run 'brew install --cask $(JDK_CASK)' without a TTY —"; \
		echo "the cask installer needs to prompt for an admin password."; \
		echo "run it yourself in a real terminal:"; \
		echo "    brew install --cask $(JDK_CASK)"; \
		exit 1; \
	fi; \
	echo "installing JDK via: brew install --cask $(JDK_CASK)"; \
	brew install --cask $(JDK_CASK)

install-jar: $(ALLOY_JAR)

$(ALLOY_JAR):
	@mkdir -p $(ALLOY_DIR)
	@echo "downloading alloy $(ALLOY_VERSION) -> $(ALLOY_JAR)"
	@curl -fL --progress-bar -o $(ALLOY_JAR).tmp $(ALLOY_URL)
	@mv $(ALLOY_JAR).tmp $(ALLOY_JAR)

update-jar:
	@rm -f $(ALLOY_JAR)
	@$(MAKE) install-jar

uninstall-jar:
	@rm -f $(ALLOY_JAR)
	@echo "removed $(ALLOY_JAR)"

check:
	@test -f $(ALLOY_JAR) || { echo "missing: $(ALLOY_JAR) — run 'make install-jar'"; exit 1; }
	@/usr/libexec/java_home -v 11+ >/dev/null 2>&1 || { echo "no JDK 11+ — run 'make install-java'"; exit 1; }
	@echo "ok: jar=$(ALLOY_JAR)  jdk=$$( /usr/libexec/java_home -v 11+ )"

doctor: check
	@JAVA="$$( /usr/libexec/java_home -v 11+ )/bin/java"; \
	echo "running: $$JAVA -jar $(ALLOY_JAR) help"; \
	"$$JAVA" -jar $(ALLOY_JAR) help 2>&1 | head -20
