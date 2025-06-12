// lib/data/mock_data.dart (actualizado con URLs válidas)

import '../../domain/entities/entities.dart';

class MockData {
  static User currentUser = User(
    id: 'user1',
    name: 'Michel Cardenas',
    email: 'michel.cardenas@uagrm.edu.bo',
    phoneNumber: '+591 71234567',
    address: 'Santa Cruz de la Sierra, Bolivia',
    profileImage: 'https://ui-avatars.com/api/?name=Michel+Cardenas&background=0d47a1&color=fff',
  );

  static List<Book> books = [
    Book(
      id: 'book1',
      title: 'Cien años de soledad',
      authors: ['Gabriel García Márquez'],
      publisher: 'Editorial Sudamericana',
      publishYear: '1967',
      category: 'Literatura',
      type: 'Físico',
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop',
      rating: 4.8,
      ratingCount: 1250,
      isAvailable: true,
      description: 'Cien años de soledad es una novela del escritor colombiano Gabriel García Márquez, ganador del Premio Nobel de Literatura en 1982. Es considerada una obra maestra de la literatura hispanoamericana y universal, así como una de las obras más traducidas y leídas en español.',
    ),
    Book(
      id: 'book2',
      title: 'El principito',
      authors: ['Antoine de Saint-Exupéry'],
      publisher: 'Éditions Gallimard',
      publishYear: '1943',
      category: 'Literatura',
      type: 'Físico',
      imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=600&fit=crop',
      rating: 4.9,
      ratingCount: 950,
      isAvailable: false,
      description: 'El principito es una novela corta y la obra más famosa del escritor y aviador francés Antoine de Saint-Exupéry. El libro se publicó en abril de 1943, tanto en inglés como en francés, pero la edición francesa no pudo ser distribuida en Francia hasta después de la liberación del país debido a la censura del régimen de Vichy.',
    ),
    Book(
      id: 'book3',
      title: 'Inteligencia Artificial: Un enfoque moderno',
      authors: ['Stuart Russell', 'Peter Norvig'],
      publisher: 'Pearson Education',
      publishYear: '2020',
      category: 'Ciencias',
      type: 'Físico',
      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=600&fit=crop',
      rating: 4.7,
      ratingCount: 382,
      isAvailable: true,
      description: 'El libro de texto estándar en el campo de la inteligencia artificial, adoptado por más de 1300 universidades en 116 países. La nueva edición cubre temas como el aprendizaje profundo, la robótica, la visión por computadora, el procesamiento del lenguaje natural y el aprendizaje por refuerzo.',
    ),
    Book(
      id: 'book4',
      title: 'Bases de Datos',
      authors: ['Abraham Silberschatz', 'Henry F. Korth', 'S. Sudarshan'],
      publisher: 'McGraw-Hill',
      publishYear: '2019',
      category: 'Ciencias',
      type: 'Digital',
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=600&fit=crop',
      rating: 4.5,
      ratingCount: 215,
      isAvailable: true,
      description: 'Este libro, conocido comúnmente como "el libro de Silberschatz", es uno de los textos principales utilizados en cursos sobre sistemas de bases de datos. Cubre desde los fundamentos hasta los temas más avanzados como la recuperación, la seguridad y el procesamiento de consultas.',
    ),
    Book(
      id: 'book5',
      title: 'Historia de Bolivia',
      authors: ['Carlos Mesa Gisbert'],
      publisher: 'Editorial Gisbert',
      publishYear: '2016',
      category: 'Historia',
      type: 'Físico',
      imageUrl: 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=400&h=600&fit=crop',
      rating: 4.3,
      ratingCount: 128,
      isAvailable: true,
      description: 'Un recorrido completo por la historia de Bolivia desde la época precolombina hasta nuestros días, escrito por el expresidente e historiador Carlos Mesa Gisbert.',
    ),
    Book(
      id: 'book6',
      title: 'Flutter y Dart: El desarrollo de apps móviles',
      authors: ['Martin Santillan'],
      publisher: 'Alfaomega',
      publishYear: '2023',
      category: 'Tecnología',
      type: 'Digital',
      imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&h=600&fit=crop',
      rating: 4.6,
      ratingCount: 97,
      isAvailable: true,
      description: 'Una guía completa para el desarrollo de aplicaciones móviles multiplataforma usando Flutter y Dart, desde los conceptos básicos hasta técnicas avanzadas.',
    ),
  ];

  static List<Book> recommendedBooks = [
    Book(
      id: 'book3',
      title: 'Inteligencia Artificial: Un enfoque moderno',
      authors: ['Stuart Russell', 'Peter Norvig'],
      publisher: 'Pearson Education',
      publishYear: '2020',
      category: 'Ciencias',
      type: 'Físico',
      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=600&fit=crop',
      rating: 4.7,
      ratingCount: 382,
      isAvailable: true,
      description: 'El libro de texto estándar en el campo de la inteligencia artificial.',
    ),
    Book(
      id: 'book6',
      title: 'Flutter y Dart: El desarrollo de apps móviles',
      authors: ['Martin Santillan'],
      publisher: 'Alfaomega',
      publishYear: '2023',
      category: 'Tecnología',
      type: 'Digital',
      imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&h=600&fit=crop',
      rating: 4.6,
      ratingCount: 97,
      isAvailable: true,
      description: 'Una guía completa para el desarrollo de aplicaciones móviles multiplataforma usando Flutter y Dart.',
    ),
    Book(
      id: 'book7',
      title: 'Clean Architecture',
      authors: ['Robert C. Martin'],
      publisher: 'Prentice Hall',
      publishYear: '2017',
      category: 'Tecnología',
      type: 'Digital',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
      rating: 4.8,
      ratingCount: 345,
      isAvailable: true,
      description: 'Una guía del famoso "Uncle Bob" sobre los principios, patrones y prácticas de la arquitectura de software.',
    ),
  ];

// En lib/data/mock_data.dart - AGREGAR/REEMPLAZAR estas partes:

// REEMPLAZAR la lista de loans:
static List<Loan> loans = [
  // ⚠️ PRÉSTAMO PRÓXIMO A VENCER - SIEMPRE PRESENTE
  Loan(
    id: 'loan_urgent',
    bookId: 'book4',
    bookTitle: 'Bases de Datos',
    bookImageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=600&fit=crop',
    loanDate: DateTime.now().subtract(const Duration(days: 13)),
    dueDate: DateTime.now().add(const Duration(days: 2)), // Vence en 2 días
    isReturned: false,
    isLate: false,
  ),
  
  // Préstamo normal
  Loan(
    id: 'loan1',
    bookId: 'book1',
    bookTitle: 'Cien años de soledad',
    bookImageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop',
    loanDate: DateTime.now().subtract(const Duration(days: 5)),
    dueDate: DateTime.now().add(const Duration(days: 10)),
    isReturned: false,
    isLate: false,
  ),
  
  // Préstamo atrasado
  Loan(
    id: 'loan2',
    bookId: 'book3',
    bookTitle: 'Inteligencia Artificial: Un enfoque moderno',
    bookImageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&h=600&fit=crop',
    loanDate: DateTime.now().subtract(const Duration(days: 20)),
    dueDate: DateTime.now().subtract(const Duration(days: 5)),
    isReturned: false,
    isLate: true,
    penalty: 10.50,
  ),
];

// AGREGAR estos métodos estáticos:
static List<Loan> getLoansExpiringSoon({int daysThreshold = 3}) {
  final now = DateTime.now();
  return loans.where((loan) {
    if (loan.isReturned || loan.isLate) return false;
    final daysUntilDue = loan.dueDate.difference(now).inDays;
    return daysUntilDue <= daysThreshold && daysUntilDue >= 0;
  }).toList();
}

static Loan? getNextExpiringLoan() {
  final expiringSoon = getLoansExpiringSoon();
  if (expiringSoon.isEmpty) return null;
  expiringSoon.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return expiringSoon.first;
}

  static List<Loan> loanHistory = [
    Loan(
      id: 'loan3',
      bookId: 'book2',
      bookTitle: 'El principito',
      bookImageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=600&fit=crop',
      loanDate: DateTime.now().subtract(const Duration(days: 45)),
      dueDate: DateTime.now().subtract(const Duration(days: 30)),
      isReturned: true,
      returnDate: DateTime.now().subtract(const Duration(days: 29)),
      isLate: false,
    ),
    Loan(
      id: 'loan4',
      bookId: 'book5',
      bookTitle: 'Historia de Bolivia',
      bookImageUrl: 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=400&h=600&fit=crop',
      loanDate: DateTime.now().subtract(const Duration(days: 90)),
      dueDate: DateTime.now().subtract(const Duration(days: 75)),
      isReturned: true,
      returnDate: DateTime.now().subtract(const Duration(days: 76)),
      isLate: true,
      penalty: 5.00,
    ),
  ];

  static List<Reservation> reservations = [
    Reservation(
      id: 'res1',
      bookId: 'book2',
      bookTitle: 'El principito',
      bookImageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=600&fit=crop',
      reservationDate: DateTime.now().subtract(const Duration(days: 2)),
      expirationDate: DateTime.now().add(const Duration(days: 3)),
      status: 'active',
    ),
  ];

  static List<Review> reviews = [
    Review(
      id: 'rev1',
      userId: 'user1',
      userName: 'Michel Cardenas',
      bookId: 'book1',
      rating: 5.0,
      comment: 'Una obra maestra de la literatura latinoamericana. La forma en que García Márquez construye Macondo y sus habitantes es simplemente genial.',
      date: DateTime.now().subtract(const Duration(days: 30)),
      helpfulVotes: 12,
      isSystemGenerated: false,
    ),
    Review(
      id: 'rev2',
      userId: 'user2',
      userName: 'Eben Ezer Cayo',
      bookId: 'book1',
      rating: 4.5,
      comment: 'Un libro que te transporta a un mundo mágico. Aunque al principio puede ser un poco confuso con tantos personajes con nombres similares.',
      date: DateTime.now().subtract(const Duration(days: 45)),
      helpfulVotes: 8,
      isSystemGenerated: false,
    ),
    Review(
      id: 'rev3',
      userId: 'system',
      userName: 'Reseña del Sistema',
      bookId: 'book1',
      rating: 4.8,
      comment: 'Los lectores destacan la narrativa magistral de Gabriel García Márquez y su capacidad para mezclar realidad y fantasía. La mayoría coincide en que es una lectura obligatoria para entender la literatura latinoamericana.',
      date: DateTime.now().subtract(const Duration(days: 10)),
      helpfulVotes: 25,
      isSystemGenerated: true,
    ),
  ];

  static List<AppNotification> notifications = [
    AppNotification(
      id: 'not1',
      title: 'Préstamo por vencer',
      message: 'Tu préstamo de "Bases de Datos" vence en 3 días.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
      type: 'loan',
    ),
    AppNotification(
      id: 'not2',
      title: 'Reserva confirmada',
      message: 'Tu reserva para "El principito" ha sido confirmada.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: 'reservation',
    ),
    AppNotification(
      id: 'not3',
      title: 'Multa pendiente',
      message: 'Tienes una multa pendiente de Bs. 10.50 por el retraso en la devolución de "Bases de Datos".',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isRead: false,
      type: 'penalty',
    ),
  ];

  static List<String> categories = [
    'Literatura',
    'Ciencias',
    'Historia',
    'Tecnología',
    'Arte',
    'Filosofía',
    'Medicina',
    'Psicología',
    'Economía',
    'Derecho',
  ];

  static List<String> chatMessages = [
    'Hola, soy el asistente virtual de la biblioteca UAGRM. ¿En qué puedo ayudarte hoy?',
    '¿Tienen disponible el libro "Cien años de soledad"?',
    'Sí, tenemos 3 ejemplares disponibles en la Biblioteca. ¿Deseas que te reserve uno?',
    'Sí, por favor.',
    'He registrado tu reserva para "Cien años de soledad". Puedes pasar a recogerlo en la Biblioteca Central desde mañana. El ID de tu reserva es: RES-2025-0587.',
  ];
}