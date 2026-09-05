runDev:
	docker build -t greeniteso-backend . && docker run --rm -it -p 8000:8000 -v $(PWD)/kit:/workspace/kit -v $(PWD)/volume/logs:/workspace/kit/logs greeniteso-backend