
BIN := ${PWD}/bin
export PATH := ${BIN}:${PATH}

CUSTOM_FORMATS := formats/custom

LICENSEI := ${BIN}/licensei
LICENSEI_VERSION = v0.8.0

${BIN}:
	mkdir -p ${BIN}

.PHONY: license-check
license-check: ${LICENSEI} ## Run license check
	${LICENSEI} check
	${LICENSEI} header

.PHONY: license-cache
license-cache: ${LICENSEI} ## Generate license cache
	${LICENSEI} cache

.PHONY: check
check: license-cache license-check

go.work:
	go work init . ${CUSTOM_FORMATS}

.PHONY:
build: go.work
	CGO_ENABLED=0 go build -a -o ${BIN}/loggen main.go

${LICENSEI}: ${LICENSEI}_${LICENSEI_VERSION} | ${BIN}
	ln -sf $(notdir $<) $@

${LICENSEI}_${LICENSEI_VERSION}: IMPORT_PATH := github.com/goph/licensei/cmd/licensei
${LICENSEI}_${LICENSEI_VERSION}: VERSION := ${LICENSEI_VERSION}
${LICENSEI}_${LICENSEI_VERSION}: | ${BIN}
	${go_install_binary}

define go_install_binary
find ${BIN} -name '$(notdir ${IMPORT_PATH})_*' -exec rm {} +
GOBIN=${BIN} go install ${IMPORT_PATH}@${VERSION}
mv ${BIN}/$(notdir ${IMPORT_PATH}) ${BIN}/$(notdir ${IMPORT_PATH})_${VERSION}
endef
