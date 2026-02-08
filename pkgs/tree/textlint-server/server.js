const express = require('express');
const bodyParser = require('body-parser');
const { spawn } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const app = express();

// Parse JSON from POST data
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

// Listen on port 8080
app.listen(8080, () => {
    console.log('Running at Port 8080...');
});

app.post('/api/textlint', async (req, res, next) => {
    // Input validation
    if (!req.body || !req.body.text) {
        return res.status(400).json({
            error: 'Missing required field: text'
        });
    }

    const req_text = req.body.text;
    const requestConfig = req.body.config;
    let tempConfigPath = null;

    try {
        // Get config file path from server.js directory
        const configPath = path.dirname(__filename);
        // Get textlint-all binary path from environment variable
        const textlintBinary = process.env.TEXTLINT_BINARY || '/nix/store/wi1ln9ld0zwc44401g6y9zcc489cqs3z-textlint-all/bin/textlint';

        // If request contains config, create temporary config file
        let configPathToUse = path.join(configPath, '.textlintrc.json');
        if (requestConfig) {
            tempConfigPath = path.join(os.tmpdir(), `textlintrc-${Date.now()}.json`);
            await fs.writeFile(tempConfigPath, JSON.stringify(requestConfig, null, 2));
            configPathToUse = tempConfigPath;
        }

        // Execute textlint-all binary directly (rules are automatically loaded via NODE_PATH)
        const child = spawn(textlintBinary, [
            '--stdin',
            '--stdin-filename', 'dummy.md',
            '--format', 'json',
            '--config', configPathToUse
        ]);

        let stdout = '';
        let stderr = '';

        child.stdout.on('data', (data) => {
            stdout += data.toString();
            console.log('Textlint stdout:', data.toString());
        });

        child.stderr.on('data', (data) => {
            stderr += data.toString();
            console.log('Textlint stderr:', data.toString());
        });

        child.on('close', async (code) => {
            // Remove temporary config file
            if (tempConfigPath) {
                try {
                    await fs.unlink(tempConfigPath);
                } catch (cleanupError) {
                    console.error('Error cleaning up temp config file:', cleanupError);
                }
            }

            try {
                // textlint returns exit code 2 when there are lint violations, but this is not an error
                // Only treat as error if code is non-zero AND there is stderr
                if (code !== 0 && stderr && stderr.length > 0) {
                    console.error('Textlint error:', stderr);
                    return res.status(500).json({
                        error: 'Textlint execution failed',
                        details: stderr
                    });
                }

                const result = JSON.parse(stdout);

                // Return the same array format that textlint outputs
                res.json(result);
            } catch (parseError) {
                console.error('Failed to parse textlint output:', parseError);
                res.status(500).json({
                    error: 'Failed to parse textlint output',
                    details: parseError.message
                });
            }
        });

        // Send text to stdin
        child.stdin.write(req_text);
        child.stdin.end();

    } catch (error) {
        console.error('TextLint execution error:', error);
        res.status(500).json({
            error: 'Internal server error during textlint execution'
        });
    }
});

// 404 error for other requests
app.use((req, res) => {
    res.sendStatus(404);
});