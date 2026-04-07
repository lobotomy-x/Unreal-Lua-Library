local functions = uevr.params.functions
UEVR_TAG = functions.get_tag()
local is_new_build = false
UEVR_COMMITS_PAST_TAG = functions.get_commits_past_tag()
UEVR_COMMIT_HASH = functions.get_commit_hash()
-- this is the imgui window name of the uevr main gui
UEVR_NAME = "UEVR ["..tostring(UEVR_TAG).."+"..tostring(UEVR_COMMITS_PAST_TAG).."-"..(tostring(UEVR_COMMIT_HASH):sub(1,8)).."]"
