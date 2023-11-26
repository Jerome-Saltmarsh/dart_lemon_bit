String cleanUrl(String directory) =>
    directory.replaceAll('\\', '/').replaceAll("//", '/');