package com.ahmadramadhan.mudahtitip.common.config;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Controller to serve the Scalar API documentation UI.
 * Scalar provides a beautiful, modern alternative to Swagger UI.
 */
@Controller
public class ScalarConfig {

    @GetMapping(value = "/docs", produces = "text/html")
    @ResponseBody
    public String scalarDocs() {
        return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Mudah Titip API - Documentation</title>
                    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>📦</text></svg>">
                </head>
                <body>
                    <script
                        id="api-reference"
                        data-url="/v3/api-docs"
                        data-configuration='{"theme": "purple", "hideModels": false}'>
                    </script>
                    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
                </body>
                </html>
                """;
    }
}
