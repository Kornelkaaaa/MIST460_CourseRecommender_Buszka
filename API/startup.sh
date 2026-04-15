#!/bin/sh
cd API && gunicorn -w 4 -k uvicorn.workers.UvicornWorker course_recommender_apis:app