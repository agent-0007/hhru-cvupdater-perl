use utf8;
package CVUpdater::DB::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CVUpdater::DB::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 mail

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 access_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 refresh_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "mail",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "access_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "refresh_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 3

=item * L</mail>

=back

=cut

__PACKAGE__->set_primary_key("mail");

=head1 RELATIONS

=head2 resumes

Type: has_many

Related object: L<CVUpdater::DB::Schema::Result::Resume>

=cut

__PACKAGE__->has_many(
  "resumes",
  "CVUpdater::DB::Schema::Result::Resume",
  { "foreign.user_id" => "self.mail" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-04-17 20:59:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C6hS+IBeUC/AV1fp620hYw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
