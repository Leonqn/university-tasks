package com.urfu;

import com.sun.corba.se.impl.orbutil.closure.*;
import org.omg.CORBA.Environment;

import javax.swing.text.html.Option;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.Future;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class CrawlerUtils {

    public static Pattern linkPattern = Pattern.compile("<a href=\"([^\"#]+)\"");

    public static String getContent(URL url) {
        StringBuilder page = new StringBuilder ();
        BufferedReader in;
        try {
            URLConnection conn = url.openConnection();
            String contentType = conn.getContentType();
                if (contentType != null && contentType.startsWith("text/html")) {
                    if (!contentType.contains("charset=")) {
                        in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
                    } else {
                        String encoding = contentType.substring(contentType.indexOf("charset=") + 8);
                        in = new BufferedReader(new InputStreamReader(conn.getInputStream(), encoding));
                    }
                    String str;
                    while ((str = in.readLine()) != null) {
                        page.append(str);
                    }
                    in.close();
                return page.toString();
            }
        } catch (Throwable e) {
        }
        return null;
    }

    public static Set<URL> getLinks(URL url, String content) {
        Set<URL> links = new HashSet<>();
        Matcher matcher = linkPattern.matcher(content);
        while (matcher.find()) {
            try {
                URL link = new URL(url, matcher.group(1));
                links.add(link);
            } catch (MalformedURLException ignored) {
            }
        }
        return links;
    }

    public static void SaveFile(Path path, String content) {
        File file = path.toFile();
        try (BufferedWriter output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"))) {
            output.write(content);
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
    }
}
