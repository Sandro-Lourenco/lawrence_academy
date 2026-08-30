from io import BytesIO

import qrcode  # type: ignore[import-untyped]
from reportlab.lib import colors  # type: ignore[import-untyped]
from reportlab.lib.pagesizes import A4, landscape  # type: ignore[import-untyped]
from reportlab.lib.utils import ImageReader  # type: ignore[import-untyped]
from reportlab.pdfbase.pdfmetrics import stringWidth  # type: ignore[import-untyped]
from reportlab.pdfgen.canvas import Canvas  # type: ignore[import-untyped]

from src.modules.certificates.domain.entities import Certificate


class ReportLabCertificateRenderer:
    """Gera um PDF A4 paisagem privado com QR de verificação pública."""

    def render(self, certificate: Certificate, verification_url: str) -> bytes:
        output = BytesIO()
        page_width, page_height = landscape(A4)
        canvas = Canvas(output, pagesize=(page_width, page_height), pageCompression=1)
        canvas.setTitle(f"Certificado - {certificate.metadata.get('course_name', '')}")
        canvas.setAuthor("Lawrence Academy")
        canvas.setSubject("Certificado de conclusão verificável")

        ivory = colors.HexColor("#FAF7F1")
        navy = colors.HexColor("#0F172A")
        wine = colors.HexColor("#811D3B")
        gold = colors.HexColor("#B8924A")
        muted = colors.HexColor("#5F5960")

        canvas.setFillColor(ivory)
        canvas.rect(0, 0, page_width, page_height, fill=1, stroke=0)
        canvas.setFillColor(navy)
        canvas.rect(0, 0, 178, page_height, fill=1, stroke=0)
        canvas.setFillColor(wine)
        canvas.rect(178, 0, 4, page_height, fill=1, stroke=0)
        canvas.setStrokeColor(gold)
        canvas.setLineWidth(1.2)
        canvas.rect(20, 20, page_width - 40, page_height - 40, fill=0, stroke=1)

        canvas.setFillColor(gold)
        canvas.setFont("Times-Bold", 74)
        canvas.drawCentredString(89, page_height / 2 + 20, "L")
        canvas.setFont("Times-Bold", 15)
        canvas.drawCentredString(89, page_height / 2 - 20, "LAWRENCE")
        canvas.setFont("Helvetica-Bold", 7.5)
        canvas.drawCentredString(89, page_height / 2 - 36, "A C A D E M Y")

        center_x = 500
        canvas.setFillColor(navy)
        canvas.setFont("Times-Bold", 28)
        canvas.drawCentredString(center_x, 510, "CERTIFICADO")
        canvas.setFont("Helvetica-Bold", 10)
        canvas.drawCentredString(center_x, 490, "D E   C O N C L U S A O")
        canvas.setStrokeColor(wine)
        canvas.line(285, 474, 715, 474)

        student_name = str(certificate.metadata.get("student_name") or "Aluno Lawrence")
        course_name = str(certificate.metadata.get("course_name") or "Formacao Lawrence")
        completion_date = str(
            certificate.metadata.get("completion_date") or certificate.issued_at.date().isoformat()
        )
        workload = certificate.metadata.get("course_workload_hours")
        lessons = certificate.metadata.get("completed_lesson_count")

        canvas.setFillColor(muted)
        canvas.setFont("Helvetica-Bold", 8.5)
        canvas.drawCentredString(center_x, 445, "CERTIFICAMOS QUE")
        self._draw_fitted_centered(canvas, student_name.upper(), center_x, 404, 26, 520)
        canvas.setStrokeColor(gold)
        canvas.line(300, 390, 700, 390)
        canvas.setFillColor(muted)
        canvas.setFont("Helvetica", 10)
        canvas.drawCentredString(center_x, 364, "concluiu integralmente a formacao")
        self._draw_fitted_centered(canvas, course_name.upper(), center_x, 330, 18, 500)

        facts = []
        if isinstance(workload, (int, float)) and workload > 0:
            formatted = f"{workload:g}".replace(".", ",")
            facts.append(f"carga horaria de {formatted} horas")
        if isinstance(lessons, int) and lessons > 0:
            facts.append(f"{lessons} aulas concluidas")
        summary = " e ".join(facts) if facts else "todos os requisitos academicos cumpridos"
        canvas.setFont("Helvetica", 9)
        canvas.setFillColor(muted)
        canvas.drawCentredString(center_x, 300, summary)

        qr_buffer = BytesIO()
        qr = qrcode.QRCode(version=None, box_size=7, border=2)
        qr.add_data(verification_url)
        qr.make(fit=True)
        qr.make_image(fill_color="#0F172A", back_color="#FAF7F1").save(qr_buffer, format="PNG")
        qr_buffer.seek(0)
        canvas.drawImage(
            ImageReader(qr_buffer),
            650,
            82,
            width=102,
            height=102,
            preserveAspectRatio=True,
            mask="auto",
        )
        canvas.setFillColor(navy)
        canvas.setFont("Helvetica-Bold", 7)
        canvas.drawCentredString(701, 68, "ESCANEIE PARA VALIDAR")

        canvas.setStrokeColor(wine)
        canvas.line(272, 132, 445, 132)
        canvas.line(470, 132, 620, 132)
        canvas.setFillColor(navy)
        canvas.setFont("Helvetica-Bold", 9)
        canvas.drawCentredString(358, 116, completion_date)
        canvas.drawCentredString(545, 116, "LAWRENCE ACADEMY")
        canvas.setFont("Helvetica", 7)
        canvas.setFillColor(muted)
        canvas.drawCentredString(358, 102, "DATA DE CONCLUSAO")
        canvas.drawCentredString(545, 102, "INSTITUICAO EMISSORA")
        canvas.setFont("Helvetica-Bold", 7.5)
        canvas.drawString(214, 51, f"CODIGO: {certificate.validation_code}")
        canvas.setFont("Helvetica", 6.5)
        canvas.drawRightString(page_width - 34, 51, verification_url)

        canvas.showPage()
        canvas.save()
        return output.getvalue()

    @staticmethod
    def _draw_fitted_centered(
        canvas: Canvas,
        text: str,
        center_x: float,
        y: float,
        preferred_size: float,
        max_width: float,
    ) -> None:
        size = preferred_size
        while size > 12 and stringWidth(text, "Times-Bold", size) > max_width:
            size -= 1
        canvas.setFillColor(colors.HexColor("#0F172A"))
        canvas.setFont("Times-Bold", size)
        canvas.drawCentredString(center_x, y, text)
