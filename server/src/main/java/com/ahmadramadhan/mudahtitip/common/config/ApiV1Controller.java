package com.ahmadramadhan.mudahtitip.common.config;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import org.springframework.web.bind.annotation.RestController;

/**
 * Meta-annotation that marks a class as an API v1 REST controller.
 * Controllers using this annotation should include the full versioned path
 * in their @RequestMapping, e.g., @RequestMapping("/api/v1/users").
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@RestController
public @interface ApiV1Controller {
}
