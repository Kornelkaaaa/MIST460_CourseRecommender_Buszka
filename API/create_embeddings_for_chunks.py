from get_db_connection import get_db_connection
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
import json


def create_embeddings_for_chunks():
    """
    Fetches all course descriptions from the database, splits each description
    into smaller text chunks, generates a vector embedding for each chunk using
    OpenAI's text-embedding-3-small model, and stores the results in the Chunks
    table via the procInsertChunk stored procedure.

    Output (written to the database):
        - ChunkText   : A substring of the original course description (max 250 chars,
                        with 20-char overlap between adjacent chunks to preserve context).
        - Embedding   : A JSON-serialized list of 1536 floats representing the semantic
                        meaning of the chunk in vector space.
        - CourseID    : Foreign key linking the chunk back to its source course.

    Console output:
        - Prints a confirmation line for each CourseID after its chunks are committed.
        - Prints a final summary line when all courses have been processed.
    """

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    # Initialize the embedding model (1536-dimensional vectors) and the splitter.
    # chunk_size=250 keeps chunks short enough for meaningful similarity searches;
    # chunk_overlap=20 ensures sentences that span chunk boundaries aren't cut off cold.
    embedding_model = OpenAIEmbeddings(model="text-embedding-3-small")
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=250, chunk_overlap=20)

    # Fetch every course row (CourseID + CourseDescription) via the stored procedure.
    cursor.execute("EXEC procGetAllCourses")
    all_courses = cursor.fetchall()

    for each_course in all_courses:
        course_id = each_course['CourseID']
        course_description = each_course['CourseDescription']

        # Split the full description into overlapping chunks.
        # Example: a 600-char description yields ~3 chunks of <=250 chars each.
        chunks_for_each_course_description = text_splitter.split_text(course_description)

        # Send all chunks for this course to OpenAI in one batch call.
        # Returns a list of float lists: [[0.012, -0.034, ...], ...], one per chunk.
        embeddings_for_chunks = embedding_model.embed_documents(chunks_for_each_course_description)

        # Insert each (chunk text, embedding, course ID) triple into the Chunks table.
        # The embedding is serialized to a JSON string because SQL Server stores it as NVARCHAR.
        for course_chunk, chunk_embedding in zip(chunks_for_each_course_description, embeddings_for_chunks):
            cursor.execute(
                "EXEC procInsertChunk %s, %s, %s",
                (course_chunk, json.dumps(chunk_embedding), course_id)
            )

        # Commit after every course so a failure mid-run doesn't roll back earlier work.
        conn.commit()
        print(f"Inserted {len(chunks_for_each_course_description)} chunk(s) and embeddings for CourseID: {course_id}")

    cursor.close()
    conn.close()
    print(f"Finished creating embeddings for all {len(all_courses)} course(s).")


# Entry point: run this script directly to populate the Chunks table.
# Prerequisite: OPENAI_API_KEY must be set in the environment (or .env file).
if __name__ == "__main__":
    create_embeddings_for_chunks()
