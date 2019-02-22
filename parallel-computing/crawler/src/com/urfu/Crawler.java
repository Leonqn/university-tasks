package com.urfu;

import java.net.URL;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.*;

public class Crawler {

    public static void Crawle(URL startUrl, int maxUrlsCount, int maxDepth, String directory) throws Exception {
        Set<URL> urlsProceed = new HashSet<>(maxUrlsCount);
        Set<URL> currentLayerUrls = new HashSet<>(maxUrlsCount);
        ConcurrentLinkedQueue<URL> urlsQueue = new ConcurrentLinkedQueue<>();
        urlsQueue.add(startUrl);
        ExecutorService executorService = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors() * 32);
        int depth = 0;
        while (urlsProceed.size() < maxUrlsCount && depth < maxDepth) {
            URL currentUrl = urlsQueue.poll();
            if (currentUrl == null) {
                Thread.sleep(5);
                continue;
            }
            if (!currentLayerUrls.contains(currentUrl)) {
                currentLayerUrls.addAll(urlsProceed);
                depth++;
            }
            String content = CrawlerUtils.getContent(currentUrl);
            if (content == null)
                continue;
            Set<URL> links = CrawlerUtils.getLinks(currentUrl, content);
            links
                    .stream()
                    .filter(url -> !urlsProceed.contains(url))
                    .distinct()
                    .forEach(url -> executorService.submit(() -> {
                        String content1 = CrawlerUtils.getContent(url);
                        if (content1 != null) {
                            urlsQueue.add(url);
                            CrawlerUtils.SaveFile(GetPath(directory), content1);
                        }
                    }));
            urlsProceed.addAll(links);
        }
        executorService.shutdown();
        executorService.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
    }

    private static Path GetPath(String dir) {
        return Paths.get(dir, UUID.randomUUID().toString());
    }
}
