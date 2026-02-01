package com.ahmadramadhan.mudahtitip.common;

import lombok.RequiredArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;

/**
 * Service for retrieving localized messages.
 * 
 * Uses the current locale from LocaleContextHolder (set by
 * AcceptHeaderLocaleResolver).
 */
@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageSource messageSource;

    /**
     * Get a localized message by key.
     * 
     * @param key the message key
     * @return the localized message
     */
    public String getMessage(String key) {
        return messageSource.getMessage(key, null, LocaleContextHolder.getLocale());
    }

    /**
     * Get a localized message by key with arguments.
     * 
     * @param key  the message key
     * @param args the message arguments
     * @return the localized message
     */
    public String getMessage(String key, Object... args) {
        return messageSource.getMessage(key, args, LocaleContextHolder.getLocale());
    }
}
