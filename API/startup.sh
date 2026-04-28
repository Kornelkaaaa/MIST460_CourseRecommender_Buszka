#!/bin/sh
gunicorn -w 4 -k uvicorn.workers.UvicornWorker --bind=0.0.0.0:8000 --timeout 600 course_recommender_apis:app
