package com.ahmadramadhan.mudahtitip.common.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI configuration for API documentation.
 */
@Configuration
public class OpenApiConfig {

        @Bean
        public OpenAPI customOpenAPI() {
                return new OpenAPI()
                                .info(new Info()
                                                .title("Mudah Titip API")
                                                .version("1.0.0")
                                                .description("REST API untuk platform konsinyasi Mudah Titip. "
                                                                + "Memungkinkan penitip (consignor) untuk menitipkan produk mereka "
                                                                + "ke berbagai toko, dengan sistem perjanjian komisi yang fleksibel.")
                                                .contact(new Contact()
                                                                .name("Mudah Titip Team")
                                                                .email("support@mudahtitip.com")))
                                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
                                .components(new Components()
                                                .addSecuritySchemes("bearerAuth",
                                                                new SecurityScheme()
                                                                                .type(SecurityScheme.Type.HTTP)
                                                                                .scheme("bearer")
                                                                                .bearerFormat("JWT")
                                                                                .description("JWT token untuk autentikasi. "
                                                                                                + "Dapatkan token dari endpoint /api/v1/auth/login")));
        }
}
