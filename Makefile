JAVA_HOME = /usr/lib/jvm/java-17-openjdk-amd64
SDK_HOME = /home/vtsv/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-4.2.4-2023-04-05-5830cc591
DEPLOY = /media/removable/GARMIN/GARMIN/APPS/
PRIVATE_KEY = ~/.Garmin/developer_key

appName = NotoRunner
DEVICE = fr245
devices = `grep 'iq:product id' manifest.xml | sed 's/.*iq:product id="\([^"]*\).*/\1/'`

clean:
	rm -rf bin

build: clean
	@$(JAVA_HOME)/bin/java \
	-Xms1g \
	-Dfile.encoding=UTF-8 \
	-Dapple.awt.UIElement=true \
	-jar "$(SDK_HOME)/bin/monkeybrains.jar" \
	-o bin/$(appName).prg \
	-f monkey.jungle \
	-y $(PRIVATE_KEY) \
	-d $(DEVICE) \
	-r -l 0 

dev:
	@$(JAVA_HOME)/bin/java \
	-Xms1g \
	-Dfile.encoding=UTF-8 \
	-Dapple.awt.UIElement=true \
	-jar "$(SDK_HOME)/bin/monkeybrains.jar" \
	-o bin/$(appName)_dev.prg \
	-f monkey.jungle \
	-y $(PRIVATE_KEY) \
	-d $(DEVICE)_sim \
	-w -l 0 

run: dev
	bash -c "$(SDK_HOME)/bin/connectiq &" && \
	$(SDK_HOME)/bin/monkeydo bin/$(appName)_dev.prg $(DEVICE)

deploy: build
	@cp bin/$(appName).prg $(DEPLOY)

package: clean
	@$(JAVA_HOME)/bin/java \
	-Dfile.encoding=UTF-8 \
  	-Dapple.awt.UIElement=true \
	-jar "$(SDK_HOME)/bin/monkeybrains.jar" \
  	-o dist/v$(version)/$(appName)-v$(version).iq \
	-e \
	-w \
	-y $(PRIVATE_KEY) \
	-r \
	-f monkey.jungle