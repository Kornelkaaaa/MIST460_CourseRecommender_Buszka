#gunicorn -w 4 -k uvicorn.workers.UvicornWorker course_recommender_apis:app
gunicorn -w 4 -k uvicorn.workers.UvicornWorker --chdir API course_recommender_apis:app