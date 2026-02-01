package com.ahmadramadhan.mudahtitip.common.config;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Meta-annotation that combines @RestController and @RequestMapping("/api/v1").
 * Use this annotation on controllers to automatically prefix all endpoints with
 * /api/v1.
 * 
 * Example:
 * 
 * <pre>
 * {@literal @}ApiV1Controller
 * {@literal @}RequestMapping("/users")  // Results in /api/v1/users
 * public class UserController { }
 * </pre>
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@RestController
@RequestMapping("/api/v1")
public @interface ApiV1Controller {
}
