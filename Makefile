# Variables
APP_NAME = MentalX
SCHEME = $(APP_NAME)
# Change "iPhone 15" par le simulateur que tu as installé
DESTINATION = 'platform=iOS Simulator,name=iPhone 17'

# Commandes
default: build

build:
	xcodebuild -scheme $(SCHEME) \
		-destination $(DESTINATION) \
		-configuration Debug \
		clean build

run:
	# 1. Build
	xcodebuild -scheme $(SCHEME) -destination $(DESTINATION) -configuration Debug build
	# 2. Boot Simulator
	open -a Simulator
	xcrun simctl bootstatus "iPhone 17" -b
	# 3. Install
	xcrun simctl install "iPhone 17" `xcodebuild -scheme $(SCHEME) -destination $(DESTINATION) -configuration Debug -showBuildSettings | grep -m 1 "TARGET_BUILD_DIR =" | awk '{print $$3}'`/$(APP_NAME).app
	# 4. Launch
	xcrun simctl launch "iPhone 17" `xcodebuild -scheme $(SCHEME) -destination $(DESTINATION) -configuration Debug -showBuildSettings | grep -m 1 "PRODUCT_BUNDLE_IDENTIFIER =" | awk '{print $$3}'`
