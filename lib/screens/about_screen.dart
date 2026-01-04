import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Extensions/extensions.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ABOUT ME heading
        Text(
          'About Me',
          style: context.textStyle.titleLgBold.copyWith(
            fontSize: 36,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 40),

        // Content section with image and text
        context.isMobile
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: const Color(0xFF7BA7BC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 150, color: Colors.white54),
          ),
        ),
        const SizedBox(width: 80),

        // About text
        Expanded(child: _buildAboutText(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Profile Image
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF7BA7BC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 100, color: Colors.white54),
          ),
        ),
        const SizedBox(height: 30),

        // About text
        _buildAboutText(context),
      ],
    );
  }

  Widget _buildAboutText(BuildContext context) {
    final textStyle = context.textStyle.bodyLgMedium.copyWith(
      height: 1.8,
      fontSize: 18,
      color: Colors.grey[300],
    );

    final linkStyle = textStyle.copyWith(
      color: Colors.white,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              const TextSpan(
                text: 'Hey! I\'m Hassan Kamran (@hassankamran) — a ',
              ),
              const TextSpan(text: 'Flutter Developer'),
              const TextSpan(
                text: ' based out of [Your Location]. I like to make ',
              ),
              TextSpan(
                text: 'cool projects',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Navigate to projects
                  },
              ),
              const TextSpan(text: ' when I\'m bored.\n\n'),

              const TextSpan(text: 'Some of my more notable projects include '),
              TextSpan(
                text: 'ProjectName1',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Link to project
                  },
              ),
              const TextSpan(text: ', where I [brief description], and '),
              TextSpan(
                text: 'ProjectName2',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Link to project
                  },
              ),
              const TextSpan(
                text:
                    ', [description]. My work focuses on mobile and web development. I maintain several projects including ',
              ),
              TextSpan(
                text: 'project1',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Link
                  },
              ),
              const TextSpan(text: ', '),
              TextSpan(
                text: 'project2',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Link
                  },
              ),
              const TextSpan(text: ', and '),
              TextSpan(
                text: 'project3',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Link
                  },
              ),
              const TextSpan(text: '.\n\n'),

              const TextSpan(text: 'Outside of software, I enjoy [hobbies], '),
              TextSpan(
                text: 'photography',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Link to photography
                  },
              ),
              const TextSpan(
                text: ', and spending time with my interests. Feel free to ',
              ),
              TextSpan(
                text: 'shoot me an email',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final uri = Uri.parse('mailto:your.email@example.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
              ),
              const TextSpan(text: ' if you\'d like to chat.'),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Social Links
        Row(
          children: [
            _buildSocialLink(
              context,
              Icons.code,
              'GitHub',
              'https://github.com/yourusername',
            ),
            const SizedBox(width: 30),
            _buildSocialLink(
              context,
              Icons.business,
              'LinkedIn',
              'https://linkedin.com/in/yourusername',
            ),
            const SizedBox(width: 30),
            _buildSocialLink(
              context,
              Icons.email,
              'contact[at][thisdomain]',
              'mailto:your.email@example.com',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLink(
    BuildContext context,
    IconData icon,
    String label,
    String url,
  ) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }
}
