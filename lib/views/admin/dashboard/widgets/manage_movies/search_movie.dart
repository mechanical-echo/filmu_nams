import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/controllers/tmdb_controller.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/edit_movie_dialog.dart';
import 'package:flutter/material.dart';

class SearchMovie extends StatefulWidget {
  const SearchMovie({super.key});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  TmdbController tmdbController = TmdbController();
  List movies = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  TextEditingController searchController = TextEditingController();

  void fetchMovies({bool loadMore = false}) {
    if (!loadMore) {
      setState(() {
        currentPage = 1;
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    tmdbController.discoverMovies(page: currentPage).then((value) {
      debugPrint(value.toString());
      setState(() {
        if (!loadMore) {
          movies = value['results'];
        } else {
          movies.addAll(value['results']);
        }
        totalPages = value['total_pages'] ?? 1;
        isLoading = false;
      });
    });
  }

  void search({bool loadMore = false}) {
    if (searchController.text.isEmpty) {
      fetchMovies();
      return;
    }

    if (!loadMore) {
      setState(() {
        currentPage = 1;
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    tmdbController
        .searchMovies(searchController.text, page: currentPage)
        .then((value) {
      debugPrint(value.toString());
      setState(() {
        if (!loadMore) {
          movies = value['results'];
        } else {
          movies.addAll(value['results']);
        }
        totalPages = value['total_pages'] ?? 1;
        isLoading = false;
      });
    });
  }

  void loadMoreMovies() {
    if (currentPage < totalPages && !isLoading) {
      currentPage++;
      if (searchController.text.isNotEmpty) {
        search(loadMore: true);
      } else {
        fetchMovies(loadMore: true);
      }
    }
  }

  void returnToAddMovie() {
    Navigator.of(context).pop();
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const EditMovieDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !isLoading &&
          currentPage < totalPages) {
        loadMoreMovies();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1020,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              spacing: 16,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_return),
                      onPressed: returnToAddMovie,
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Meklēt pēc nosaukuma',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => search(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => search(),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => fetchMovies(),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: card(index),
                            );
                          },
                        ),
                      ),
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget card(int index) {
    return TMDBMovieCard(movie: movies[index]);
  }
}

class TMDBMovieCard extends StatefulWidget {
  const TMDBMovieCard({
    super.key,
    required this.movie,
  });

  final dynamic movie;

  @override
  State<TMDBMovieCard> createState() => _TMDBMovieCardState();
}

class _TMDBMovieCardState extends State<TMDBMovieCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          TmdbController().getMovieDetails(widget.movie['id']).then((value) {
            final movie = MovieModel.fromMap({
              'title': value['title'],
              'description': value['overview'],
              'poster-url':
                  'https://image.tmdb.org/t/p/w500${value['poster_path']}',
              'duration': value['runtime'],
              'rating': '',
              'genre': value['genres'][0]['name'],
              'director': '',
              'hero-url':
                  'https://image.tmdb.org/t/p/w500${value['backdrop_path']}',
              'actors': [],
              'premiere': Timestamp.fromDate(
                DateTime.parse(value['release_date']),
              ),
            }, 'new');
            if (context.mounted) {
              Navigator.of(context).pop();
              showGeneralDialog(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return EditMovieDialog(data: movie);
                },
                transitionBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              );
            }
          }).catchError((error) {
            debugPrint('Error fetching movie details: $error');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching movie details: $error'),
                ),
              );
            }
          });
        },
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${widget.movie['poster_path']}',
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 40,
                  ),
                ),
              ),
              fit: BoxFit.cover,
            ),
            AnimatedContainer(
              padding: const EdgeInsets.all(15),
              duration: Durations.short3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isHovered ? Colors.black54 : Colors.transparent,
              ),
              child: AnimatedOpacity(
                opacity: isHovered ? 1.0 : 0.0,
                duration: Durations.short3,
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 30,
                      ),
                    ),
                    Text(widget.movie['title']),
                    Text(
                      widget.movie['overview'] ?? 'No description available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
