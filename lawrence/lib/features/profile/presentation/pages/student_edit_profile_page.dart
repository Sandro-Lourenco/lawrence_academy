import 'dart:ui';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/providers/service_repositories.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../../../design_system/widgets/couture_progress_bar.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../controllers/student_profile_controller.dart';
import '../../domain/entities/user_profile.dart';

class StudentEditProfilePage extends ConsumerStatefulWidget {
  const StudentEditProfilePage({super.key});

  @override
  ConsumerState<StudentEditProfilePage> createState() =>
      _StudentEditProfilePageState();
}

class _StudentEditProfilePageState
    extends ConsumerState<StudentEditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _certificateNameController;
  late TextEditingController _urlUsernameController;
  late TextEditingController _emailController;
  late TextEditingController _biographyController;
  late TextEditingController _birthDateController;
  late TextEditingController _occupationController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  late TextEditingController _githubController;
  late TextEditingController _customUrlController;

  bool _openToOpportunities = false;
  bool _isUploadingAvatar = false;
  bool _profileLoaded = false;
  String? _avatarUrl;
  List<AcademicFormation> _academicFormations = const [];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _certificateNameController = TextEditingController();
    _urlUsernameController = TextEditingController();
    _emailController = TextEditingController();
    _biographyController = TextEditingController();
    _birthDateController = TextEditingController();
    _occupationController = TextEditingController();
    _companyController = TextEditingController();
    _jobTitleController = TextEditingController();
    _linkedinController = TextEditingController();
    _twitterController = TextEditingController();
    _githubController = TextEditingController();
    _customUrlController = TextEditingController();

    ref.listenManual(
      studentProfileProvider,
      (_, next) => next.whenData((profile) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _populateProfileFields(profile),
        );
      }),
      fireImmediately: true,
    );
  }

  void _populateProfileFields(UserProfile profile) {
    if (_profileLoaded || !mounted) return;
    _profileLoaded = true;
    _fullNameController.text = profile.fullName ?? '';
    _certificateNameController.text = profile.certificateName ?? '';
    _urlUsernameController.text = profile.urlUsername ?? '';
    _emailController.text = profile.email;
    _biographyController.text = profile.biography ?? '';
    _occupationController.text = profile.occupation ?? '';
    _companyController.text = profile.company ?? '';
    _jobTitleController.text = profile.jobTitle ?? '';
    _openToOpportunities = profile.openToOpportunities;
    _linkedinController.text = profile.linkedinUrl ?? '';
    _twitterController.text = profile.twitterUrl ?? '';
    _githubController.text = profile.githubUrl ?? '';
    _customUrlController.text = profile.customUrl ?? '';
    _avatarUrl = profile.avatarUrl;
    _academicFormations = List<AcademicFormation>.from(
      profile.academicFormations,
    );
    if (profile.birthDate != null) {
      _birthDateController.text =
          '${profile.birthDate!.day.toString().padLeft(2, '0')}/'
          '${profile.birthDate!.month.toString().padLeft(2, '0')}/'
          '${profile.birthDate!.year}';
    }
    setState(() {});
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final file = result.files.first;
      final fileBytes = file.bytes;
      final fileName = file.name;

      Uint8List? uploadBytes = fileBytes;
      if (uploadBytes == null && !kIsWeb && file.path != null) {
        uploadBytes = await io.File(file.path!).readAsBytes();
      }

      if (uploadBytes == null) {
        throw Exception(
          'Não foi possível ler os bytes do arquivo selecionado.',
        );
      }

      final profileAsync = ref.read(studentProfileProvider);
      final profile = profileAsync.value;
      if (profile == null) {
        throw Exception('Perfil não carregado.');
      }

      final publicUrl = await ref
          .read(uploadProfileAvatarUseCaseProvider)
          .execute(userId: profile.id, fileName: fileName, bytes: uploadBytes);

      setState(() {
        _avatarUrl = publicUrl;
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto de perfil alterada! Clique em salvar para confirmar.',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
      );
    }
  }

  Future<void> _requestPasswordChange() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    try {
      await ref.read(requestPasswordResetUseCaseProvider).execute(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos um link seguro para alterar sua senha.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível enviar o link. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _addAcademicFormation() async {
    final course = TextEditingController();
    final institution = TextEditingController();
    final type = TextEditingController();
    final formation = await showDialog<AcademicFormation>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar formação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: course,
              decoration: const InputDecoration(labelText: 'Curso'),
            ),
            TextField(
              controller: institution,
              decoration: const InputDecoration(labelText: 'Instituição'),
            ),
            TextField(
              controller: type,
              decoration: const InputDecoration(
                labelText: 'Tipo (curso, técnico, graduação…)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (course.text.trim().isEmpty ||
                  institution.text.trim().isEmpty ||
                  type.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(
                dialogContext,
                AcademicFormation(
                  id: 'local-${DateTime.now().microsecondsSinceEpoch}',
                  course: course.text.trim(),
                  institution: institution.text.trim(),
                  type: type.text.trim(),
                ),
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    course.dispose();
    institution.dispose();
    type.dispose();
    if (formation != null && mounted) {
      setState(() => _academicFormations = [..._academicFormations, formation]);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _certificateNameController.dispose();
    _urlUsernameController.dispose();
    _emailController.dispose();
    _biographyController.dispose();
    _birthDateController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    int totalFields = 11;
    int filledFields = 0;

    if (_fullNameController.text.isNotEmpty) filledFields++;
    if (_certificateNameController.text.isNotEmpty) filledFields++;
    if (_urlUsernameController.text.isNotEmpty) filledFields++;
    if (_biographyController.text.isNotEmpty) filledFields++;
    if (_birthDateController.text.isNotEmpty) filledFields++;
    if (_occupationController.text.isNotEmpty) filledFields++;
    if (_companyController.text.isNotEmpty) filledFields++;
    if (_jobTitleController.text.isNotEmpty) filledFields++;
    if (_linkedinController.text.isNotEmpty) filledFields++;
    if (_githubController.text.isNotEmpty) filledFields++;
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) filledFields++;

    return filledFields / totalFields;
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileAsync = ref.read(studentProfileProvider);
      final profile = profileAsync.value;
      if (profile == null) return;

      DateTime? birthDate;
      if (_birthDateController.text.isNotEmpty) {
        final parts = _birthDateController.text.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            birthDate = DateTime(year, month, day);
          }
        }
      }

      final updatedProfile = profile.copyWith(
        fullName: _fullNameController.text,
        certificateName: _certificateNameController.text,
        urlUsername: _urlUsernameController.text,
        biography: _biographyController.text,
        birthDate: birthDate,
        occupation: _occupationController.text,
        company: _companyController.text,
        jobTitle: _jobTitleController.text,
        openToOpportunities: _openToOpportunities,
        linkedinUrl: _linkedinController.text,
        twitterUrl: _twitterController.text,
        githubUrl: _githubController.text,
        customUrl: _customUrlController.text,
        avatarUrl: _avatarUrl,
        academicFormations: _academicFormations,
      );

      final success = await ref
          .read(editProfileControllerProvider.notifier)
          .updateProfile(updatedProfile);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
          context.pop();
        } else {
          final error = ref.read(editProfileControllerProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar alterações: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(studentProfileProvider);
    if (!_profileLoaded && profileState.isLoading) {
      return const Scaffold(
        body: AppLoadingState(message: 'Preparando seu ateliê pessoal…'),
      );
    }
    if (!_profileLoaded && profileState.hasError) {
      return Scaffold(
        body: AppErrorState(
          title: 'Não foi possível abrir seu perfil',
          message: 'Verifique sua conexão e tente novamente.',
          onRetry: () => ref.invalidate(studentProfileProvider),
        ),
      );
    }
    final progress = _calculateProgress();
    final editState = ref.watch(editProfileControllerProvider);
    final isLoading = editState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SEU PERFIL',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: LawrenceColors.canvasParchment,
        foregroundColor: LawrenceColors.brandNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        color: LawrenceColors.canvasParchment,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              Widget content = Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: LawrenceSpacing.sm,
                            runSpacing: LawrenceSpacing.xs,
                            children: [
                              const Text(
                                'Nível do seu perfil',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.help_outline,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                          const SizedBox(height: LawrenceSpacing.md),
                          CoutureProgressBar(
                            value: progress,
                            height: 10,
                            semanticLabel: 'Nível de preenchimento do perfil',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.lg),
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: LawrenceSpacing.md,
                            runSpacing: LawrenceSpacing.sm,
                            children: [
                              Text(
                                'Formação acadêmica',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              OutlinedButton.icon(
                                onPressed: _addAcademicFormation,
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar'),
                              ),
                            ],
                          ),
                          if (_academicFormations.isEmpty) ...[
                            const SizedBox(height: LawrenceSpacing.md),
                            const Text(
                              'Adicione cursos e formações relevantes para seu percurso.',
                            ),
                          ] else
                            for (final formation in _academicFormations)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(formation.course),
                                subtitle: Text(
                                  '${formation.institution} · ${formation.type}',
                                ),
                                trailing: IconButton(
                                  tooltip: 'Remover formação',
                                  onPressed: () => setState(
                                    () => _academicFormations =
                                        _academicFormations
                                            .where(
                                              (item) => item.id != formation.id,
                                            )
                                            .toList(),
                                  ),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.lg),
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dados gerais',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: LawrenceSpacing.lg),
                          Flex(
                            direction: isWide ? Axis.horizontal : Axis.vertical,
                            crossAxisAlignment: isWide
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                button: true,
                                label: 'Alterar foto do perfil',
                                child: InkWell(
                                  onTap: _isUploadingAvatar
                                      ? null
                                      : _pickAndUploadAvatar,
                                  borderRadius: BorderRadius.circular(40),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor:
                                            LawrenceColors.infoSurface,
                                        backgroundImage:
                                            _avatarUrl != null &&
                                                _avatarUrl!.isNotEmpty
                                            ? NetworkImage(_avatarUrl!)
                                            : null,
                                        child: _isUploadingAvatar
                                            ? const CircularProgressIndicator()
                                            : (_avatarUrl == null ||
                                                      _avatarUrl!.isEmpty
                                                  ? Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: LawrenceColors
                                                          .brandNavy,
                                                    )
                                                  : null),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: isWide ? LawrenceSpacing.md : 0,
                                height: isWide ? 0 : LawrenceSpacing.md,
                              ),
                              if (isWide)
                                Expanded(
                                  child: Text(
                                    'Toque na foto para enviar uma imagem. Se preferir, manteremos sua foto atual.',
                                    style: TextStyle(
                                      color: LawrenceColors.brandNavy,
                                      height: 1.4,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'Toque na foto para enviar uma imagem. Se preferir, manteremos sua foto atual.',
                                  style: TextStyle(
                                    color: LawrenceColors.brandNavy,
                                    height: 1.4,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: LawrenceSpacing.xl),
                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Nome completo',
                                    _fullNameController,
                                  ),
                                ),
                                const SizedBox(width: LawrenceSpacing.md),
                                Expanded(
                                  child: _buildTextField(
                                    'Nome nos certificados',
                                    _certificateNameController,
                                    hint: '(alteração somente 1 vez)',
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              'Nome completo',
                              _fullNameController,
                            ),
                            const SizedBox(height: LawrenceSpacing.md),
                            _buildTextField(
                              'Nome nos certificados',
                              _certificateNameController,
                              hint: '(alteração somente 1 vez)',
                            ),
                          ],
                          const SizedBox(height: LawrenceSpacing.md),
                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Usuário na URL',
                                    _urlUsernameController,
                                    hint: '(só minúsculas, min 6 caracteres)',
                                  ),
                                ),
                                const SizedBox(width: LawrenceSpacing.md),
                                Expanded(
                                  child: _buildTextField(
                                    'E-mail',
                                    _emailController,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              'Usuário na URL',
                              _urlUsernameController,
                              hint: '(só minúsculas, min 6 caracteres)',
                            ),
                            const SizedBox(height: LawrenceSpacing.md),
                            _buildTextField(
                              'E-mail',
                              _emailController,
                              enabled: false,
                            ),
                          ],
                          const SizedBox(height: LawrenceSpacing.md),
                          TextButton.icon(
                            onPressed: _requestPasswordChange,
                            icon: const Icon(Icons.lock_outline, size: 18),
                            label: const Text('Alterar senha'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.lg),
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sobre você',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: LawrenceSpacing.lg),
                          _buildTextField(
                            'Biografia',
                            _biographyController,
                            maxLines: 5,
                          ),
                          const SizedBox(height: LawrenceSpacing.md),
                          _buildTextField(
                            'Data de nascimento',
                            _birthDateController,
                            hint: 'Exemplo: 08 / 07 / 1997',
                          ),
                          const SizedBox(height: LawrenceSpacing.md),
                          _buildTextField(
                            'Ocupação',
                            _occupationController,
                            hint: 'Estudante, Desenvolvedor, etc.',
                          ),
                          const SizedBox(height: LawrenceSpacing.md),
                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Empresa',
                                    _companyController,
                                  ),
                                ),
                                const SizedBox(width: LawrenceSpacing.md),
                                Expanded(
                                  child: _buildTextField(
                                    'Cargo',
                                    _jobTitleController,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField('Empresa', _companyController),
                            const SizedBox(height: LawrenceSpacing.md),
                            _buildTextField('Cargo', _jobTitleController),
                          ],
                          const SizedBox(height: LawrenceSpacing.md),
                          Material(
                            type: MaterialType.transparency,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: _openToOpportunities,
                              onChanged: (value) => setState(
                                () => _openToOpportunities = value ?? false,
                              ),
                              title: const Text(
                                'Aberto(a) a novas oportunidades',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Mostre no perfil que você aceita propostas profissionais.',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.lg),
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suas redes',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: LawrenceSpacing.lg),
                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Linkedin',
                                    _linkedinController,
                                    hint: '(link completo)',
                                  ),
                                ),
                                const SizedBox(width: LawrenceSpacing.md),
                                Expanded(
                                  child: _buildTextField(
                                    'Twitter',
                                    _twitterController,
                                    hint: '(link completo)',
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              'Linkedin',
                              _linkedinController,
                              hint: '(link completo)',
                            ),
                            const SizedBox(height: LawrenceSpacing.md),
                            _buildTextField(
                              'Twitter',
                              _twitterController,
                              hint: '(link completo)',
                            ),
                          ],
                          const SizedBox(height: LawrenceSpacing.lg),
                          Text(
                            'Seus projetos na web',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: LawrenceSpacing.lg),
                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Github',
                                    _githubController,
                                    hint: '(link completo)',
                                  ),
                                ),
                                const SizedBox(width: LawrenceSpacing.md),
                                Expanded(
                                  child: _buildTextField(
                                    'Link personalizado',
                                    _customUrlController,
                                    hint: '(link completo)',
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              'Github',
                              _githubController,
                              hint: '(link completo)',
                            ),
                            const SizedBox(height: LawrenceSpacing.md),
                            _buildTextField(
                              'Link personalizado',
                              _customUrlController,
                              hint: '(link completo)',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.xl),
                    CouturePrimaryButton(
                      onPressed: isLoading ? null : _saveProfile,
                      loading: isLoading,
                      expand: true,
                      icon: Icons.check_rounded,
                      label: 'SALVAR ALTERAÇÕES',
                    ),
                    const SizedBox(height: LawrenceSpacing.xl),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(LawrenceSpacing.xl),
                        child: content,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: LawrenceSpacing.xl,
                          right: LawrenceSpacing.xl,
                        ),
                        child: _buildChecklistCard(),
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(LawrenceSpacing.md),
                child: Column(
                  children: [
                    content,
                    const SizedBox(height: LawrenceSpacing.lg),
                    _buildChecklistCard(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: enabled ? (value) => _validateField(label, value) : null,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: LawrenceColors.brandNavy,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: TextStyle(color: Colors.blueGrey.shade700),
        filled: true,
        fillColor: enabled
            ? Colors.white.withOpacity(0.7)
            : Colors.grey.shade200.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  String? _validateField(String label, String? value) {
    final input = value?.trim() ?? '';
    if (label == 'Nome completo' && input.length < 2) {
      return 'Informe seu nome completo.';
    }
    if (label == 'Usuário na URL' &&
        input.isNotEmpty &&
        !RegExp(r'^[a-z0-9_]{6,30}$').hasMatch(input)) {
      return 'Use 6–30 caracteres: letras minúsculas, números ou _.';
    }
    if (label == 'Data de nascimento' && input.isNotEmpty) {
      final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(input);
      if (match == null) return 'Use o formato DD/MM/AAAA.';
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Informe uma data válida.';
      }
    }
    const urlFields = {'Linkedin', 'Twitter', 'Github', 'Link personalizado'};
    if (urlFields.contains(label) && input.isNotEmpty) {
      final uri = Uri.tryParse(input);
      if (uri == null ||
          !{'http', 'https'}.contains(uri.scheme) ||
          uri.host.isEmpty) {
        return 'Informe um link completo, começando com https://.';
      }
    }
    return null;
  }

  Widget _buildChecklistCard() {
    return _buildGlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: LawrenceColors.brandNavy,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Check-list do perfil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildChecklistItem(
                  'Foto de perfil',
                  _avatarUrl != null && _avatarUrl!.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Nome completo',
                  _fullNameController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Nome nos certificados',
                  _certificateNameController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Usuário na URL',
                  _urlUsernameController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Biografia',
                  _biographyController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Data de nascimento',
                  _birthDateController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Ocupação',
                  _occupationController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Empresa',
                  _companyController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Cargo',
                  _jobTitleController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Linkedin',
                  _linkedinController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Github',
                  _githubController.text.isNotEmpty,
                ),
                _buildChecklistItem(
                  'Formação Acadêmica',
                  _academicFormations.isNotEmpty,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check : Icons.keyboard_arrow_down,
            color: isDone ? Colors.blueAccent : Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDone
                    ? Colors.blueGrey.shade700
                    : Colors.blueGrey.shade400,
                fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
