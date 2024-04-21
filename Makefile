lambda:
	cd ingestion/querido-diario-ingestor; poetry build
	cd ingestion/querido-diario-ingestor; poetry run pip install --upgrade -t package dist/*.whl
	cd ingestion/querido-diario-ingestor/package; zip -r ../lambda.zip . -x '*.pyc'
