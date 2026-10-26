# Create the runner and start the configuration experience
./config.sh --url https://github.com/AmentumCMS --token $GITHUB_RUNNER_TOKEN \
    --name $(hostname)  --runnergroup cms --labels rhel$RHEL_VERSION \
    --work _work --unattended
# Last step, run it!
./run.sh