import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKey() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email',
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "expencetracker-9f731",
        "private_key_id": "34db92f431032551188072d19e3ff49a6ffb1943",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC8mQrw0HnulQd9\nWlM2B2mbaC7pN/aJkk0Ye8g4/G873LygQz9D+c6EwJhJ/8/vVpEUgtxr7jIjS8pd\nZ9nK8+zkUBtgJLsrayV+P/P/3ntY0p8XQhXSsbntsPhu00F4OGhLdxmJNWh+J+zY\noghvrvX0FXGPO1bjHJn8F/6JUXMioKW//iLEP5P13lllFOU9DrOoOolQ6mj6afQs\nmfGNRQ025NCO0Ym89ZRfS1ESMf/Yuuta694l8a+Ppdb/rKZjnZDV1LgWYvhpuLPX\nco7ImoNgn3gFgafvOy7phlJS58P1vtYxW1GuXWIZqp1nnrxgMZCuPlAZ+EVMrpbj\nRXA0v2BBAgMBAAECggEAA9BGBY/E1Dg01vbbaLCs4ZsxTguQ2dmySWTakmk4VP0m\nEa+KbFt1Lsxq+x2uT+g8nGEqoXWtk3a8eGsMxZFtIHWMno/flDjHoOfpWfeSH74S\njXilBexy4zi8ehed4uQKtKWLewswOiAG8zjdJs6VsDVtMgVz8+yBVWgLmfpvQF7D\n2viE62tDWw3KkMGZE6cJXDq5jluh7LoM5gnloXXyiLJviyIhphYIQ92wQ5EkoLau\nFiFcvH9G5l1FUukgZQ4fA4NlqQ3dtjfcjhJ4TeT0YYpSagzIw9fFOtD86tA+yvQr\nP5xD+6oYA6TMoFfByyB8QLRbnKET8fSbweAM1Bfc6QKBgQD9RQEl7+7OmnJRjMwg\n9jQxRn/FLA7Udo0aDwLB7ifZvuZfvv0vgSXvz94llqk6M2pgr/MEogpVrnlVouj1\n2buEveCIs/npQMPJDOce0dzWuhfCfgiq7IqxQzBxfMoMQrmLWPG9Ru9bfig0DwVB\nMxPlFSwtz70oI2Ti8LOvFhXn3wKBgQC+oY0yd7WJpHQj8XFxljB4ogC8+vqWr8H0\n6Vsh/caUtMYQOobaTroX8jAtexuglUxyP4RPxIAAUGlgy8sqIO0Vb88tXY53Ety8\nhLmmcnDkCSWpGAwv9zoivhfNtiILJw0OxVfO/T59HXorJ2GCp8TZzuNmo5PxOd8f\nuZSOBAY73wKBgFdyT+ctZKLpKLeHiaOH3pV05gDKKYSqOiXZMPaMqC3CgABnDTwt\nt0+J0gXgcyWpQv2HQr1CxZa32yT6Tr00JE680J3iplMnDXKJhfNaOonZTwLUSWHa\nsjhqHnvQvmJlV3MJjs3vhA1vDaqL1SCh5iiemtZmd8U4E0lYGnJFieK5AoGBAKfy\n1t4uv17L55K/Jg5Hnt65A+N7TwkxQbVPXn39AlaDSbiEh8iP8b4lHrMDMhzxTE+f\njCdm3MrqDV09TvoH1ji7sBCsy1Y25Qil+pYdXz5YnLh0OlCMBMkVJw2SuD2RIxzv\nWmQ/ky1Rqg+Y+3zL6E9oycnktfOh4+UkcDAKdZ+LAoGBAOKxyTWJM0Az1Uo+5EQE\n7CbqfkNxqqBPaWg7g5nhGfEVZHXVGcAz8WlthjIhahkUlCOPZE7pRfEe7ETauISO\nQ69RH/Av1vV9+VXLgArlYJdJ5nDgj8L8n8Zh53/5EwDvfMWbvsElZX+hKlw0MP7s\nCTZ8Cz5j5mCVYXwa6+Jeos4Q\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@expencetracker-9f731.iam.gserviceaccount.com",
        "client_id": "109041946131217593514",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40expencetracker-9f731.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessToken = client.credentials.accessToken.data;

    return accessToken;
  }
}
