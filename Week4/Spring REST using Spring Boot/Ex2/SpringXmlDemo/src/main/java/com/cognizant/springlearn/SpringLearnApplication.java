package com.cognizant.springlearn;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class SpringLearnApplication {
    private static final Logger LOGGER = LoggerFactory.getLogger(SpringLearnApplication.class);

    public static void main(String[] args) {
        displayCountry();
    }

    public static void displayCountry() {
        ApplicationContext context = new ClassPathXmlApplicationContext("country.xml");

        Country country1 = (Country) context.getBean("country_US");
        LOGGER.debug("Country : {}", country1);

        Country country2 = (Country) context.getBean("country_IN");
        LOGGER.debug("Country : {}", country2);

        Country country3 = (Country) context.getBean("country_FR");
        LOGGER.debug("Country : {}", country3);

        Country country4 = (Country) context.getBean("country_JP");
        LOGGER.debug("Country : {}", country4);
    }
}
