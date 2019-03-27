#!/usr/bin/env bash
set -e
################################################################################
# This executes a small subset of the edx-platform tests.  It is intended as
# a means of testing newly provisioned AMIs for our jenkins workers.
#
# The two main things that happen here:
#   1. The setup from edx-platform/scripts/all-tests.sh, the script that is
#      run by the jenkins workers to kick off tests.
#   2. The paver command for tests, coverage and quality reports are run.
#      For the tests, it runs only a small number of test cases for each
#      test suite.
###############################################################################

# Doing this rather than copying the file into the scripts folder so that
# this file doesn't get cleaned out by the 'git clean' in all-tests.sh.
cd edx-platform-clone

# This will run all of the setup it usually runs, but none of the
# tests because TEST_SUITE isn't defined.
source scripts/jenkins-common.sh

case "$1" in
    "unit")

        # Now we can run a subset of the tests via paver.
        # Run some of the common/lib unit tests
        paver test_lib -t common/lib/xmodule/xmodule/tests/test_stringify.py 2> /dev/null

        # Generate some coverage reports
        paver coverage 2> /dev/null

        # Run some of the djangoapp unit tests
        paver test_system -t lms/djangoapps/courseware/tests/tests.py 2> /dev/null
        paver test_system -t cms/djangoapps/course_creators/tests/test_views.py 2> /dev/null
        ;;

    "js")

        # Run some of the javascript unit tests
        paver test_js_run -s lms-coffee 2> /dev/null
        ;;

    "bokchoy")

        # Run some of the bok-choy tests
        paver test_bokchoy -t discussion/test_discussion.py::DiscussionTabSingleThreadTest 2> /dev/null
        paver test_bokchoy -t studio/test_studio_outline.py::WarningMessagesTest::test_unreleased_published_locked --fasttest 2> /dev/null
        paver test_bokchoy -t lms/test_lms_matlab_problem.py::MatlabProblemTest --fasttest 2> /dev/null
        ;;

    "quality")
        # Generate quality reports
        paver run_quality 2> /dev/null
        ;;

    *)
        echo "args required"
        exit 1
esac
