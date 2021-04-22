test:
	@docker build -t nginx-brotli-so-test .
	@echo "#"
	@echo "# Open: http://localhost:7462/"
	@echo "#"
	@docker run --rm -p 7462:80 nginx-brotli-so-test
