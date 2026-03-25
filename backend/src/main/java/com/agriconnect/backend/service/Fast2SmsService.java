package com.agriconnect.backend.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;

@Slf4j
@Service
public class Fast2SmsService {

    @Value("${twilio.account-sid:}")
    private String accountSid;

    @Value("${twilio.auth-token:}")
    private String authToken;

    @Value("${twilio.phone-number:}")
    private String twilioPhone;

    @Value("${twilio.enabled:false}")
    private boolean enabled;

    @PostConstruct
    public void init() {
        if (enabled && accountSid != null && !accountSid.isBlank()) {
            Twilio.init(accountSid, authToken);
            log.info("Twilio initialized successfully");
        }
    }

    public boolean sendOtp(String mobile, String otp) {

        if (!enabled || accountSid == null || accountSid.isBlank()) {
            log.warn("DEV MODE - SMS not sent | Mobile: {} | OTP: {}", mobile, otp);
            return true;
        }

        try {
            String mob = mobile.replaceAll("\\D", "");
            if (mob.length() == 10) mob = "+91" + mob;
            else if (mob.length() == 12) mob = "+" + mob;

            String messageBody = "Your AgriConnect OTP is " + otp
                    + ". Valid for 10 minutes. Do not share with anyone.";

            Message message = Message.creator(
                    new PhoneNumber(mob),
                    new PhoneNumber(twilioPhone),
                    messageBody
            ).create();

            log.info("OTP SMS sent! SID: {} | To: ******{}",
                    message.getSid(), mob.substring(mob.length() - 4));
            return true;

        } catch (Exception e) {
            log.error("Twilio SMS error: {}", e.getMessage());
            return false;
        }
    }
}