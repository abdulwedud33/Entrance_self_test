-- Complete the transition from the legacy Department-based schema to the
-- current stream, subject, and instructor model.
CREATE TYPE "Stream" AS ENUM ('NATURAL_SCIENCE', 'SOCIAL_SCIENCE');
CREATE TYPE "SubjectType" AS ENUM ('STREAM_SPECIFIC', 'SHARED');
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE');

ALTER TYPE "Role" ADD VALUE 'INSTRUCTOR';

ALTER TABLE "Student" DROP CONSTRAINT "Student_departmentId_fkey";

ALTER TABLE "ExamAttempt"
  ADD COLUMN "subjectId" TEXT,
  ADD COLUMN "year" INTEGER;

ALTER TABLE "ExamConfig"
  ADD COLUMN "naturalPassword" TEXT NOT NULL DEFAULT 'natural123',
  ADD COLUMN "socialPassword" TEXT NOT NULL DEFAULT 'social123';

UPDATE "ExamConfig"
SET "naturalPassword" = "password",
    "socialPassword" = "password";

ALTER TABLE "ExamConfig" DROP COLUMN "password";

ALTER TABLE "Question" ADD COLUMN "subjectId" TEXT;

ALTER TABLE "Student"
  DROP COLUMN "departmentId",
  ADD COLUMN "gender" "Gender" NOT NULL DEFAULT 'MALE',
  ADD COLUMN "stream" "Stream" NOT NULL DEFAULT 'NATURAL_SCIENCE';

ALTER TABLE "Student"
  ALTER COLUMN "gender" DROP DEFAULT;

DROP TABLE "Department";

CREATE TABLE "Instructor" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "stream" "Stream" NOT NULL,

    CONSTRAINT "Instructor_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Subject" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "stream" "Stream",
    "type" "SubjectType" NOT NULL DEFAULT 'STREAM_SPECIFIC',

    CONSTRAINT "Subject_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Instructor_userId_key" ON "Instructor"("userId");

ALTER TABLE "Instructor"
  ADD CONSTRAINT "Instructor_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Instructor"
  ADD CONSTRAINT "Instructor_subjectId_fkey"
  FOREIGN KEY ("subjectId") REFERENCES "Subject"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Question"
  ADD CONSTRAINT "Question_subjectId_fkey"
  FOREIGN KEY ("subjectId") REFERENCES "Subject"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "ExamAttempt"
  ADD CONSTRAINT "ExamAttempt_subjectId_fkey"
  FOREIGN KEY ("subjectId") REFERENCES "Subject"("id") ON DELETE SET NULL ON UPDATE CASCADE;

UPDATE "Subject"
SET "type" = 'SHARED',
    "stream" = NULL
WHERE lower("name") IN ('english', 'aptitude');
