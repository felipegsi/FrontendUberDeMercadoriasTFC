//enum categoria
enum Category {
  SMALL,
  MEDIUM,
  LARGE,
  MOTORIZED
}

// Utility function to convert string to enum
Category getCategoryFromString(String categoryStr) {
  switch (categoryStr.toUpperCase()) {
    case 'SMALL':
      return Category.SMALL;
    case 'MEDIUM':
      return Category.MEDIUM;
    case 'LARGE':
      return Category.LARGE;
    case 'MOTORIZED':
      return Category.MOTORIZED;
    default:
      throw Exception('Invalid category');
  }
}