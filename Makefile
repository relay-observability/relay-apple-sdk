.PHONY: test lint format build bootstrap

bootstrap:
	@echo "🔧 Bootstrapping project"
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit
	brew list swiftlint &>/dev/null || brew install swiftlint
	brew list swiftformat &>/dev/null || brew install swiftformat

build:
	@echo "📦 Building for platform: $(PLATFORM)"
	xcodebuild \
		-destination "generic/platform=$(PLATFORM)" \
		-scheme Relay \
		-sdk iphonesimulator \
		build

build-ios:
	@$(MAKE) build PLATFORM=ios

build-macos:
	@$(MAKE) build PLATFORM=macos

build-tvos:
	@$(MAKE) build PLATFORM=tvOS

test:
	swift test --parallel

lint:
	swiftlint --strict

format:
	swiftformat --lint Sources/ Tests/

coverage:
	./scripts/coverage.sh
